{
  lib,
  pkgsCross,
  zynq-utils,
}:

{
  name,
  src,
  flash-qspi-cmd,
  ...
}@args:
lib.makeExtensibleWithCustomName "overrideAttrs" (final: {
  hwplat =
    (zynq-utils.hwplat {
      inherit name;
      src = builtins.path {
        path = src;
        name = "vivado-srcs";
      };
    }).override
      (lib.attrsets.optionalAttrs (args ? hwplat) args.hwplat);

  sdt =
    (zynq-utils.sdt {
      hwplat = final.hwplat;
    }).override
      (lib.attrsets.optionalAttrs (args ? sdt) args.sdt);

  pmufw =
    (pkgsCross.microblaze-embedded.zynq-utils.pmufw {
      sdt = final.sdt;
    }).override
      (lib.attrsets.optionalAttrs (args ? pmufw) args.pmufw);

  fsbl =
    (pkgsCross.aarch64-embedded.zynq-utils.fsbl {
      sdt = final.sdt;
    }).override
      (lib.attrsets.optionalAttrs (args ? fsbl) args.fsbl);

  tfa = (pkgsCross.aarch64-multiplatform.zynq-utils.tfa { plat = "zynqmp"; }).override (
    lib.attrsets.optionalAttrs (args ? tfa) args.tfa
  );

  uboot =
    (pkgsCross.aarch64-multiplatform.zynq-utils.uboot {
      defconfig = "xilinx_zynqmp_virt_defconfig";
      extDeviceTreeBlob = final.sdt.dtb;
    }).override
      (lib.attrsets.optionalAttrs (args ? uboot) args.uboot);

  boot-image =
    (zynq-utils.boot-image {
      hwplat = final.hwplat;
      sdt = final.sdt;
      pmufw = final.pmufw;
      fsbl = final.fsbl;
      tfa = final.tfa;
      uboot = final.uboot;
    }).override
      (lib.attrsets.optionalAttrs (args ? boot-image) args.boot-image);

  boot-jtag-cmd =
    (zynq-utils.boot-jtag-cmd {
      hwplat = final.hwplat;
      sdt = final.sdt;
      pmufw = final.pmufw;
      fsbl = final.fsbl;
      tfa = final.tfa;
      uboot = final.uboot;
    }).override
      (lib.attrsets.optionalAttrs (args ? boot-jtag-cmd) args.boot-jtag-cmd);

  flash-qspi-cmd =
    (zynq-utils.flash-qspi-cmd {
      bootImage = final.boot-image;
      dowFsbl = final.fsbl;
      flashType = args.flash-qspi-cmd.flashType;
      flashDensity = args.flash-qspi-cmd.flashDensity;
    }).override
      (lib.attrsets.optionalAttrs (args ? flash-qspi-cmd) args.flash-qspi-cmd);
})
