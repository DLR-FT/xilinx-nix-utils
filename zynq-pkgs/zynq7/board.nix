{
  lib,
  pkgsCross,
  zynq-pkgs,
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
    (zynq-pkgs.hwplat {
      inherit name;
      src = args.hwplat.src;
    }).override
      (lib.attrsets.optionalAttrs (args ? hwplat) args.hwplat);

  sdt =
    (zynq-pkgs.sdt {
      hwplat = final.hwplat;
    }).override
      (lib.attrsets.optionalAttrs (args ? sdt) args.sdt);

  fsbl =
    (pkgsCross.armhf-embedded.zynq-pkgs.fsbl {
      sdt = final.sdt;
      plat = "zynq7";
      proc = "ps7_cortexa9_0";
    }).override
      (lib.attrsets.optionalAttrs (args ? fsbl) args.fsbl);

  linux-dt =
    (zynq-pkgs.linux-dt {
      sdt = final.sdt;
      proc = "ps7_cortexa9_0";
    }).override
      (lib.attrsets.optionalAttrs (args ? linux-dt) args.linux-dt);

  uboot =
    (pkgsCross.armv7l-hf-multiplatform.zynq-pkgs.uboot {
      defconfig = "xilinx_zynq_virt_defconfig";
      extDeviceTreeBlob = final.linux-dt.dtb;
    }).override
      (lib.attrsets.optionalAttrs (args ? uboot) args.uboot);

  boot-image =
    let
      toSnake = lib.strings.stringAsChars (ch: if ch == "-" then "_" else ch);
      bootBif = ''
        ${toSnake final.hwplat.baseName}:
        {
          [bootloader] ${final.fsbl.elf}
          ${final.hwplat.bit}
          ${final.uboot.elf}
          [load = 0x00100000] ${final.linux-dt.dtb}
        }
      '';
    in
    (zynq-pkgs.boot-image {
      baseName = final.hwplat.baseName;
      arch = "zynq";
      bootBif = bootBif;
    }).override
      (lib.attrsets.optionalAttrs (args ? boot-image) args.boot-image);

  flash-qspi =
    (zynq-pkgs.flash-qspi {
      bootImage = final.boot-image;
      initFsbl = final.fsbl;
      flashPart = args.flash-qspi.flashPart;
    }).override
      (lib.attrsets.optionalAttrs (args ? flash-qspi) args.flash-qspi);
})
