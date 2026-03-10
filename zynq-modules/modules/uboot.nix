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
      type = with lib.types; strMatching "[a-zA-Z0-9_-]+";
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
      description = "Specifies the U-Boot source repo (e.g. github:xilinx/u-boot-xlnx).";
      default = pkgs.zynq-srcs.uboot-src;
    };

    defconfig = lib.mkOption {
      type = with lib.types; singleLineStr;
      description = "Specifies the U-Boot defconfig for the build.";
    };

    bl31 = lib.mkOption {
      type = with lib.types; nullOr path;
      description = "Specifies the BL31 binary (*.elf) for the U-Boot build. Can be null to ignore BL31.";
      default = null;
    };

    tee = lib.mkOption {
      type = with lib.types; nullOr path;
      description = "Specifies the TEE / BL32 binary (*.elf) for the U-Boot build. Can be null to ignore BL32.";
      default = null;
    };

    deviceTree = lib.mkOption {
      type = with lib.types; nullOr (either path singleLineStr);
      description = "Specifies either an U-Boot interal device-tree name or an external device-tree blob to be included in the U-Boot build.";
      default = null;
    };

    extraConfigs = lib.mkOption {
      type = with lib.types; listOf singleLineStr;
      description = "Specifies extra config options to append to the U-Boot defconfig.";
      default = [ ];
    };

    extraMakeFlags = lib.mkOption {
      type = with lib.types; listOf singleLineStr;
      description = "Specifies extra Make flags for the build.";
      default = [ ];
    };

    extraPatches = lib.mkOption {
      type = with lib.types; listOf path;
      description = "Specifies extra patches to apply to the source directory before the build.";
      default = [ ];
    };

    stdenv = lib.mkOption {
      type = with lib.types; package;
      description = "Specifies the stdenv toolchain used to build the U-Boot firmware.";
    };

    package = lib.mkOption {
      type = with lib.types; package;
      description = "Package containing the build U-Boot firmware.";
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
        destination_cpu = lib.mkIf (config.plat == "zynqmp") (lib.mkDefault "a53-0");
        exception_level = lib.mkIf (config.plat == "zynqmp") (lib.mkDefault "el-2");
      };
      file = lib.mkDefault config.uboot.package.elf;
    };
    boot-jtag.uboot = lib.mkDefault config.uboot.package.elf;
  };
}
