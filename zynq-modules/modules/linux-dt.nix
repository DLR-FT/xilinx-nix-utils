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
      type = with lib.types; strMatching "[a-zA-Z0-9_-]+";
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
      description = "Specifies the Lopper source repo (e.g. github:devicetree-org/lopper).";
      default = pkgs.zynq-srcs.lopper-src;
    };

    systemDeviceTree = lib.mkOption {
      type = with lib.types; path;
      description = "Specifies the System-Device-Tree that is used to generate the Linux-Device-Tree.";
    };

    procId = lib.mkOption {
      type =
        with lib.types;
        enum [
          "ps7_cortexa9_0"
          "ps7_cortexa9_1"
          "psu_cortexa53_0"
          "psu_cortexa53_1"
          "psu_cortexa53_2"
          "psu_cortexa53_3"
        ];
      description = "Specifies the Zynq processor (ps7_cortexa9_0, psu_cortexa53_0, ...) for which the Linux-Device-Tree is build.";
      default =
        {
          zynq7 = "ps7_cortexa9_0";
          zynqmp = "psu_cortexa53_0";
        }
        .${config.plat};
    };

    extraLops = lib.mkOption {
      type = with lib.types; listOf singleLineStr;
      description = ''
        Specifies extra lops (overrides, modifications, etc) to apply,
        when generating the Linux-Device-Tree from the System-Device-Tree (see github:devicetree-org/lopper).'';
      default = [ ];
    };

    extraDtsi = lib.mkOption {
      type = with lib.types; listOf path;
      description = "Specifies extra device-tree includes for the Linux DTB.";
      default = [ ];
    };

    extraPatches = lib.mkOption {
      type = with lib.types; listOf path;
      description = "Specifies extra patches to apply to the source directory before the build.";
      default = [ ];
    };

    package = lib.mkOption {
      type = with lib.types; package;
      description = "Package containing the build Linux Device-Tree";
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
