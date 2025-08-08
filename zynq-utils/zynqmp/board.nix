{
  lib,
  pkgsCross,
  zynq-utils,
}:

{
  # Name of the project
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

  pmufw =
    (pkgsCross.microblaze-embedded.zynq-utils.pmufw {
      sdt = final.sdt;
      plat = "zynqmp";
      proc = "psu_pmu_0";
    }).override
      (lib.attrsets.optionalAttrs (args ? pmufw) args.pmufw);

  fsbl =
    (pkgsCross.aarch64-embedded.zynq-utils.fsbl {
      sdt = final.sdt;
      plat = "zynqmp";
      proc = "psu_cortexa53_0";
    }).override
      (lib.attrsets.optionalAttrs (args ? fsbl) args.fsbl);

  tfa = (pkgsCross.aarch64-multiplatform.zynq-utils.tfa { plat = "zynqmp"; }).override (
    lib.attrsets.optionalAttrs (args ? tfa) args.tfa
  );

  linux-dt =
    (zynq-utils.linux-dt {
      sdt = final.sdt;
      proc = "psu_cortexa53_0";
    }).override
      (lib.attrsets.optionalAttrs (args ? linux-dt) args.linux-dt);

  uboot =
    (pkgsCross.aarch64-multiplatform.zynq-utils.uboot {
      defconfig = "xilinx_zynqmp_virt_defconfig";
      extDeviceTreeBlob = final.linux-dt.dtb;
    }).override
      (lib.attrsets.optionalAttrs (args ? uboot) args.uboot);

  boot-image =
    let
      toSnake = lib.strings.stringAsChars (ch: if ch == "-" then "_" else ch);
      bootBif = ''
        ${toSnake final.hwplat.baseName}:
        {
          [bootloader, destination_cpu = a53-0] ${final.fsbl.elf}
          [pmufw_image] ${final.pmufw.elf}
          [destination_device = pl] ${final.hwplat.bit}
          [destination_cpu = a53-0, exception_level = el-3, trustzone] ${final.tfa.elf}
          [destination_cpu = a53-0, exception_level = el-2] ${final.uboot.elf}
          [destination_cpu = a53-0, load = 0x00100000] ${final.linux-dt.dtb}
        }
      '';
    in
    (zynq-utils.boot-image {
      baseName = final.hwplat.baseName;
      arch = "zynqmp";
      bootBif = bootBif;

    }).override
      (lib.attrsets.optionalAttrs (args ? boot-image) args.boot-image);

  boot-jtag =
    (zynq-utils.zynqmp.boot-jtag {
      hwplat = final.hwplat;
      pmufw = final.pmufw;
      fsbl = final.fsbl;
      tfa = final.tfa;
      uboot = final.uboot;
    }).override
      (lib.attrsets.optionalAttrs (args ? boot-jtag) args.boot-jtag);

  flash-qspi =
    (zynq-utils.flash-qspi {
      bootImage = final.boot-image;
      initFsbl = final.fsbl;
      flashPart = args.flash-qspi.flashPart;
    }).override
      (lib.attrsets.optionalAttrs (args ? flash-qspi) args.flash-qspi);
})
