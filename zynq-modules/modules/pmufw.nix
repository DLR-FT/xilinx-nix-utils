{
  config,
  lib,
  pkgs,
  ...
}:
{
  options.pmufw = {
    name = lib.mkOption {
      type = with lib.types; singleLineStr;
      description = "name";
      default = config.name + "-pmufw";
    };

    version = lib.mkOption {
      type = with lib.types; nullOr singleLineStr;
      description = "version";
      default = null;
    };

    src = lib.mkOption {
      type = with lib.types; path;
      description = "PMU source repo (github: xilinx/embdeddedsw).";
      default = pkgs.zynq-srcs.embeddedsw-src;
    };

    proc = lib.mkOption {
      type = with lib.types; singleLineStr;
      description = "Zynq processor id (ps7_cortexa9_0, psu_cortexa53_0, psu_pmu_0, ...).";
      default = { zynqmp = "psu_pmu_0"; }.${config.plat};
    };

    extraPatches = lib.mkOption {
      type = with lib.types; listOf path;
      description = "Extra patches to apply to the src repo.";
      default = [ ];
    };

    stdenv = lib.mkOption {
      type = with lib.types; package;
      description = "stdenv used to build the pmufw.";
      default = { "psu_pmu_0" = pkgs.pkgsCross.microblaze-embedded.stdenv; }.${config.pmufw.proc};
    };

    package = lib.mkOption {
      type = with lib.types; nullOr package;
      description = "Package containing the PMU firmware.";
      default = null;
    };
  };

  config = {
    fwPackages = [ config.pmufw.package ];

    pmufw = {
      package = lib.mkDefault (
        pkgs.zynq-pkgs.pmufw {
          name = config.pmufw.name;
          version = config.pmufw.version;
          src = config.pmufw.src;
          stdenv = config.pmufw.stdenv;

          sdt = config.sdt.package;
          plat = config.plat;
          proc = config.pmufw.proc;
          extraPatches = config.pmufw.extraPatches;
        }
      );
    };
  };
}
