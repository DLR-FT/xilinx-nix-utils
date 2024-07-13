{ lib, runCommandNoCC, xilinx-unified }:

{ platform ? "zynq7000" }:

runCommandNoCC "check-commands-${platform}" { nativeBuildInputs = [ xilinx-unified ]; } ''
  source ${./..}/utils.sh
  
  create-project ${lib.strings.escapeShellArg platform} "$out" nix_test
  build-hw-config "$out/nix_test"
  build-bootloader ${lib.strings.escapeShellArg platform} "$out/nix_test"
''
