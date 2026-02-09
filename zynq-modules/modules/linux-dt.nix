{
  config,
  lib,
  pkgs,
  ...
}:
{
  options.linux-dt = {
    enable = lib.mkEnableOption "Enable Linux Device-Tree build." // {
      default = true;
    };

    name = lib.mkOption {
      type = with lib.types; singleLineStr;
      description = "name";
      default = config.name + "-linux-dt";
    };

    version = lib.mkOption {
      type = with lib.types; nullOr singleLineStr;
      description = "version";
      default = null;
    };

    src = lib.mkOption {
      type = with lib.types; path;
      description = "Lopper source repo (github:devicetree-org/lopper).";
      default = pkgs.zynq-srcs.lopper-src;
    };

    systemDeviceTree = lib.mkOption {
      type = with lib.types; path;
      description = "System-Device-Tree sources.";
    };

    procId = lib.mkOption {
      type = with lib.types; singleLineStr;
      description = "Zynq processor id (ps7_cortexa9_0, psu_cortexa53_0, psu_pmu_0, ...).";
      default =
        {
          zynq7 = "ps7_cortexa9_0";
          zynqmp = "psu_cortexa53_0";
        }
        .${config.plat};
    };

    extraLops = lib.mkOption {
      type = with lib.types; listOf singleLineStr;
      description = "Extra lops to apply (see github:devicetree-org/lopper).";
      default = [ ];
    };

    extraDtsi = lib.mkOption {
      type = with lib.types; listOf path;
      description = "Extra dtsi to include in the linux dtb.";
      default = [ ];
    };

    extraPatches = lib.mkOption {
      type = with lib.types; listOf path;
      description = "Extra patches to apply to the src repo.";
      default = [ ];
    };

    package = lib.mkOption {
      type = with lib.types; package;
      description = "Package containing the Linux Device-Tree";
    };
  };

  config = lib.mkIf config.linux-dt.enable {
    fwPackages = [ config.linux-dt.package ];

    linux-dt = {
      package = lib.mkDefault (
        pkgs.zynq-pkgs.linux-dt {
          name = config.linux-dt.name;
          version = config.linux-dt.version;
          src = config.linux-dt.src;

          sdt = config.linux-dt.systemDeviceTree;
          proc = config.linux-dt.procId;
          extraLops = config.linux-dt.extraLops;
          extraDtsi = config.linux-dt.extraDtsi;
          extraPatches = config.linux-dt.extraPatches;
        }
      );
    };

    uboot.deviceTree = lib.mkDefault config.linux-dt.package.dtb;
    boot-image.partitions.dtb = {
      order = 700;
      options = {
        load = "0x00100000";
      };
      file = config.linux-dt.package.dtb;
    };
    boot-jtag.dtb = lib.mkDefault config.linux-dt.package.dtb;
    boot-jtag.dtbAddr = lib.mkDefault (
      {
        zynq7 = "0x00100000";
        zynqmp = "0x00100000";
      }
      .${config.plat}
    );
  };
}
