{
  lib,
  stdenv,
  xilinx-unified,
}:

{
  prjName,
  prjSrc,
}:
let
  buildHwplatTcl = ''
    open_project ./${prjName}/${prjName}.xpr

    launch_runs impl_1 -to_step write_bitstream -job $env(NIX_BUILD_CORES)
    wait_on_run impl_1

    open_run impl_1

    write_bitstream ./${prjName}/${prjName}.bit
    write_hw_platform ./${prjName}/${prjName}.xsa
  '';
in
stdenv.mkDerivation (finalAttrs: {
  name = "${prjName}-hw";
  src = "${prjSrc}";

  nativeBuildInputs = [ xilinx-unified ];

  dontPatch = true;

  configurePhase = ''
    vivado -nolog -nojournal -mode batch -source ${prjSrc}/vivado.tcl -tclargs --origin_dir ./. --project_name ${prjName}
    echo ${lib.strings.escapeShellArg buildHwplatTcl} > ./${prjName}/build-hw.tcl
  '';

  buildPhase = ''
    vivado -nolog -nojournal -mode batch -source ./${prjName}/build-hw.tcl
  '';

  doCheck = false;
  installPhase = ''
    cp -r -- ./${prjName} $out
  '';

  dontFixup = true;
  dontPatchELF = true;
  dontPatchShebangs = true;
  doInstallCheck = false;
  doDist = false;

  passthru = {
    bit = "${finalAttrs.finalPackage.out}/${prjName}.bit";
    xsa = "${finalAttrs.finalPackage.out}/${prjName}.xsa";
    xpr = "${finalAttrs.finalPackage.out}/${prjName}.xpr";
  };
})
