{ fetchFromGitHub, arm-trusted-firmware }:

{
  atf-src ? (
    fetchFromGitHub {
      owner = "Xilinx";
      repo = "arm-trusted-firmware";
      rev = "xilinx-v2024.1";
      hash = "sha256-XEFHS2hZWdJEB7b0Zdci/PtNc7csn+zQWljiG9Tx0mM=";
    }
  ),
}:
(arm-trusted-firmware.buildArmTrustedFirmware {
  platform = "zynqmp";
  extraMakeFlags = [ "bl31" ];
  filesToInstall = [
    "build/zynqmp/release/bl31/bl31.elf"
    "build/zynqmp/release/bl31.bin"
  ];
}).overrideAttrs
  (
    final: prev: {
      src = atf-src;

      passthru = {
        elf = "${final.finalPackage.out}/bl31.elf";
      };
    }
  )
