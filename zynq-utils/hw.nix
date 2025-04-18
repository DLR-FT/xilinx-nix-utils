{
  lib,
  stdenv,
  xilinx-unified,
}:

{
  prj-name,
  prj-src,
  ...
}:
let
  build_hw_tcl = ''
    open_project ./${prj-name}/${prj-name}.xpr

    launch_runs impl_1 -to_step write_bitstream -job 8
    wait_on_run impl_1

    open_run impl_1

    write_bitstream ./${prj-name}/${prj-name}.bit
    write_hw_platform ./${prj-name}/${prj-name}.xsa
  '';
in
stdenv.mkDerivation (finalAttrs: {
  name = "${prj-name}-hw";
  src = "${prj-src}";

  nativeBuildInputs = [ xilinx-unified ];

  dontPatch = true;

  configurePhase = ''
    vivado -nolog -nojournal -mode batch -source ${prj-src}/vivado.tcl -tclargs --origin_dir ./. --project_name ${prj-name}
    echo ${lib.strings.escapeShellArg build_hw_tcl} > ./${prj-name}/build-hw.tcl
  '';

  buildPhase = ''
    vivado -nolog -nojournal -mode batch -source ./${prj-name}/build-hw.tcl
  '';

  doCheck = false;
  installPhase = ''
    cp -r -- ./${prj-name} $out
  '';

  dontFixup = true;
  dontPatchELF = true;
  dontPatchShebangs = true;
  doInstallCheck = false;
  doDist = false;

  passthru = {
    bit = "${finalAttrs.finalPackage.out}/${prj-name}.bit";
    xpr = "${finalAttrs.finalPackage.out}/${prj-name}.xpr";
  };
})
