{
  config,
  lib,
  pkgs,
  ...
}:
{
  options.linux-dt = {
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

    proc = lib.mkOption {
      type = with lib.types; singleLineStr;
      description = "Zynq processor id (ps7_cortexa9_0, psu_cortexa53_0, psu_pmu_0, ...).";
      default = { zynqmp = "psu_cortexa53_0"; }.${config.plat};
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
      type = with lib.types; nullOr package;
      description = "Package containing the Linux Device-Tree";
      default = null;
    };
  };

  config = {
    fwPackages = [ config.linux-dt.package ];

    linux-dt = {
      package = lib.mkDefault (
        pkgs.zynq-pkgs.linux-dt {
          name = config.linux-dt.name;
          version = config.linux-dt.version;
          src = config.linux-dt.src;

          sdt = config.sdt.package;
          proc = config.linux-dt.proc;
          extraLops = config.linux-dt.extraLops;
          extraDtsi = config.linux-dt.extraDtsi;
          extraPatches = config.linux-dt.extraPatches;
        }
      );
    };
  };
}
