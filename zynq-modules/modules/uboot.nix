{
  config,
  lib,
  pkgs,
  ...
}:
{
  options.uboot = {
    enable = lib.mkEnableOption "Enable BL33 U-Boot build.";

    name = lib.mkOption {
      type = with lib.types; singleLineStr;
      description = "name";
      default = config.name + "-uboot";
    };

    version = lib.mkOption {
      type = with lib.types; nullOr singleLineStr;
      description = "version";
      default = null;
    };

    src = lib.mkOption {
      type = with lib.types; path;
      description = "U-Boot source repo (github: xilinx/u-boot-xlnx).";
      default = pkgs.zynq-srcs.uboot-src;
    };

    defconfig = lib.mkOption {
      type = with lib.types; singleLineStr;
      description = "U-Boot defconfig to build.";
    };

    bl31 = lib.mkOption {
      type = with lib.types; nullOr path;
      description = "BL31 binary (*.elf).";
      default = null;
    };

    tee = lib.mkOption {
      type = with lib.types; nullOr path;
      description = "TEE / BL32 binary (*.elf).";
      default = null;
    };

    deviceTree = lib.mkOption {
      type = with lib.types; nullOr (either path singleLineStr);
      description = "U-Boot device-tree name.";
      default = null;
    };

    extraConfigs = lib.mkOption {
      type = with lib.types; listOf singleLineStr;
      description = "Extra config options.";
      default = [ ];
    };

    extraMakeFlags = lib.mkOption {
      type = with lib.types; listOf singleLineStr;
      description = "Extra make flags.";
      default = [ ];
    };

    extraPatches = lib.mkOption {
      type = with lib.types; listOf path;
      description = "Extra patches to apply to the src repo.";
      default = [ ];
    };

    stdenv = lib.mkOption {
      type = with lib.types; package;
      description = "stdenv used to build the U-Boot firmware.";
    };

    package = lib.mkOption {
      type = with lib.types; package;
      description = "Package containing the U-Boot firmware.";
    };
  };

  config = {
    fwPackages = [ config.uboot.package ];

    uboot = {
      defconfig = lib.mkDefault (
        {
          zynq7 = "xilinx_zynq_virt_defconfig";
          zynqmp = "xilinx_zynqmp_virt_defconfig";
        }
        .${config.plat}
      );

      stdenv = lib.mkDefault (
        {
          zynq7 = pkgs.pkgsCross.armv7l-hf-multiplatform.stdenv;
          zynqmp = pkgs.pkgsCross.aarch64-multiplatform.stdenv;
        }
        .${config.plat}
      );

      package = lib.mkDefault (
        pkgs.zynq-pkgs.uboot {
          name = config.uboot.name;
          version = config.uboot.version;
          src = config.uboot.src;
          stdenv = config.uboot.stdenv;

          defconfig = config.uboot.defconfig;
          bl31 = config.uboot.bl31;
          tee = config.uboot.tee;
          deviceTree = config.uboot.deviceTree;
          extraConfigs = config.uboot.extraConfigs;
          extraMakeFlags = config.uboot.extraMakeFlags;
          extraPatches = config.uboot.extraPatches;
        }
      );
    };

    boot-image.partitions.uboot = {
      order = 600;
      options = lib.mkIf (config.plat == "zynqmp") {
        exception_level = lib.mkIf (config.plat == "zynqmp") (lib.mkDefault "el-2");
      };
      file = config.uboot.package.elf;
    };
    boot-jtag.uboot = lib.mkDefault config.uboot.package.elf;
  };
}
