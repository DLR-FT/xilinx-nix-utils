{
  arm-trusted-firmware,
  zynq-utils,
}:

{
  atf-src ? zynq-utils.tfa-src,
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
