{
  lib,
  pkgsCross,
  zynq-utils,
}:

{
  name,
  hwplat,
  flash-qspi,
  ...
}@args:
lib.makeExtensibleWithCustomName "overrideAttrs" (final: {
  hwplat =
    (zynq-utils.hwplat {
      inherit name;
      src = args.hwplat.src;
    }).override
      (lib.attrsets.optionalAttrs (args ? hwplat) args.hwplat);

  sdt =
    (zynq-utils.sdt {
      hwplat = final.hwplat;
    }).override
      (lib.attrsets.optionalAttrs (args ? sdt) args.sdt);

  fsbl =
    (pkgsCross.armhf-embedded.zynq-utils.fsbl {
      sdt = final.sdt;
      plat = "zynq7";
      proc = "ps7_cortexa9_0";
    }).override
      (lib.attrsets.optionalAttrs (args ? fsbl) args.fsbl);

  linux-dt =
    (zynq-utils.linux-dt {
      sdt = final.sdt;
      proc = "ps7_cortexa9_0";
    }).override
      (lib.attrsets.optionalAttrs (args ? linux-dt) args.linux-dt);

  uboot =
    (pkgsCross.armv7l-hf-multiplatform.zynq-utils.uboot {
      defconfig = "xilinx_zynq_virt_defconfig";
      extDeviceTreeBlob = final.linux-dt.dtb;
    }).override
      (lib.attrsets.optionalAttrs (args ? uboot) args.uboot);

  boot-image =
    (zynq-utils.zynq7.boot-image {
      hwplat = final.hwplat;
      fsbl = final.fsbl;
      uboot = final.uboot;
    }).override
      (lib.attrsets.optionalAttrs (args ? boot-image) args.boot-image);

  boot-jtag =
    (zynq-utils.zynq7.boot-jtag {
      hwplat = final.hwplat;
      fsbl = final.fsbl;
      uboot = final.uboot;
    }).override
      (lib.attrsets.optionalAttrs (args ? boot-jtag) args.boot-jtag);

  flash-qspi =
    (zynq-utils.flash-qspi {
      bootImage = final.boot-image;
      dowFsbl = final.fsbl;
      flashType = args.flash-qspi-cmd.flashType;
      flashDensity = args.flash-qspi-cmd.flashDensity;
    }).override
      (lib.attrsets.optionalAttrs (args ? flash-qspi) args.flash-qspi);
})
