{
  lib,
  stdenv,
  xilinx-unified,

  name ? null,
  version ? null,
  src,

  sourceTcl ? "./vivado.tcl",
  originDir ? "./.",

  extraPatches ? [ ],
}@args:

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

    ${lib.optionalString (sourceTcl != null) ''
      vivado -nolog -nojournal -mode batch \
        -source ${sourceTcl} \
        -tclargs \
        ${lib.optionalString (originDir != null) "--origin_dir ${originDir}"} \
        --project_name ${name}
    ''}

    prj_file=$(find . -type f -name "*.xpr")
    if [ ! -e "$prj_file" ]; then
      echo "Project *.xpr not found!"
      exit 1
    fi

    prj_dir=$(dirname $prj_file)

    runHook postConfigure
  '';

  buildPhase = ''
    runHook preBuild

    vivado -nolog -nojournal -mode batch \
      -source ${../scripts/build-hwplat.tcl} \
      -tclargs \
      -prj_file $prj_file \
      -name ${name} \
      -out $prj_dir \
      -jobs $NIX_BUILD_CORES

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    cp -r -- $prj_dir $out

    runHook postInstall
  '';

  dontFixup = true;

  passthru = {
    bit = "${finalAttrs.finalPackage.out}/${name}.bit";
    xsa = "${finalAttrs.finalPackage.out}/${name}.xsa";
  };
})
