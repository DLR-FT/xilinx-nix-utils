{
  config,
  lib,
  pkgs,
  ...
}:
{
  options.uboot = {
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

    proc = lib.mkOption {
      type = with lib.types; singleLineStr;
      description = "Zynq processor id (ps7_cortexa9_0, psu_cortexa53_0, psu_pmu_0, ...).";
      default = { zynqmp = "psu_cortexa53_0"; }.${config.plat};
    };

    defconfig = lib.mkOption {
      type = with lib.types; singleLineStr;
      description = "U-Boot defconfig to build.";
      default =
        {
          ps7_cortexa9_0 = "xilinx_zynq_virt_defconfig";
          psu_cortexa53_0 = "xilinx_zynqmp_virt_defconfig";
        }
        .${config.uboot.proc};
    };

    deviceTree = lib.mkOption {
      type = with lib.types; nullOr (either path singleLineStr);
      description = "U-Boot device-tree name.";
      default = config.linux-dt.package.dtb;
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
      default = { "psu_cortexa53_0" = pkgs.pkgsCross.aarch64-multiplatform.stdenv; }.${config.uboot.proc};
    };

    package = lib.mkOption {
      type = with lib.types; nullOr package;
      description = "Package containing the U-Boot firmware.";
      default = null;
    };
  };

  config = {
    fwPackages = [ config.uboot.package ];

    uboot = {
      package = lib.mkDefault (
        pkgs.zynq-pkgs.uboot {
          name = config.uboot.name;
          version = config.uboot.version;
          src = config.uboot.src;
          stdenv = config.uboot.stdenv;

          defconfig = config.uboot.defconfig;
          bl31 = config.tfa.package.elf;
          tee = if config.optee-os.enable then config.optee-os.package.elf else null;
          deviceTree = config.uboot.deviceTree;
          extraConfigs = config.uboot.extraConfigs;
          extraMakeFlags = config.uboot.extraMakeFlags;
          extraPatches = config.uboot.extraPatches;
        }
      );
    };
  };
}
