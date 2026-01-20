{
  lib,
  stdenv,
  xilinx-unified,

  name ? null,
  version ? null,
  src,

  sourceTcl ? src + "/vivado.tcl",
  extraPatches ? [ ],
}@args:
let
  buildHwplatTcl = ''
    open_project ./${name}/${name}.xpr

    launch_runs impl_1 -to_step write_bitstream -job $env(NIX_BUILD_CORES)
    wait_on_run impl_1

    open_run impl_1

    write_bitstream ./${name}/${name}.bit
    write_hw_platform ./${name}/${name}.xsa
  '';
in
stdenv.mkDerivation (finalAttrs: {
  name = if args.name != null then args.name else "zynq-hwplat";
  version =
    if args.version != null then
      args.version
    else if (finalAttrs.src ? rev) then
      finalAttrs.src.rev
    else
      "unstable";

  inherit src;

  nativeBuildInputs = [ (lib.lowPrio xilinx-unified) ];

  patches = [ ] ++ extraPatches;

  configurePhase = ''
    runHook preConfigure

    vivado -nolog -nojournal -mode batch -source ${sourceTcl} -tclargs --origin_dir ./. --project_name ${name}
    echo ${lib.strings.escapeShellArg buildHwplatTcl} > ./${name}/build-hw.tcl

    runHook postConfigure
  '';

  buildPhase = ''
    runHook preBuild

    vivado -nolog -nojournal -mode batch -source ./${name}/build-hw.tcl

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    cp -r -- ./${name} $out

    runHook postInstall
  '';

  dontFixup = true;

  passthru = {
    bit = "${finalAttrs.finalPackage.out}/${name}.bit";
    xsa = "${finalAttrs.finalPackage.out}/${name}.xsa";
    xpr = "${finalAttrs.finalPackage.out}/${name}.xpr";
  };
})
