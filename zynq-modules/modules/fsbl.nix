{
  config,
  lib,
  pkgs,
  ...
}:
{
  options.fsbl = {
    name = lib.mkOption {
      type = with lib.types; singleLineStr;
      description = "name";
      default = config.name + "-fsbl";
    };

    version = lib.mkOption {
      type = with lib.types; nullOr singleLineStr;
      description = "version";
      default = null;
    };

    src = lib.mkOption {
      type = with lib.types; path;
      description = "FSBL source repo (github: xilinx/embeddedsw).";
      default = pkgs.zynq-srcs.embeddedsw-src;
    };

    proc = lib.mkOption {
      type = with lib.types; singleLineStr;
      description = "Zynq processor id (ps7_cortexa9_0, psu_cortexa53_0, psu_pmu_0, ...).";
      default = { zynqmp = "psu_cortexa53_0"; }.${config.plat};
    };

    extraPatches = lib.mkOption {
      type = with lib.types; listOf path;
      description = "Extra patches to apply to the src repo.";
      default = [ ];
    };

    stdenv = lib.mkOption {
      type = with lib.types; package;
      description = "stdenv used to build the fsbl.";
      default = { "psu_cortexa53_0" = pkgs.pkgsCross.aarch64-embedded.stdenv; }.${config.fsbl.proc};
    };

    package = lib.mkOption {
      type = with lib.types; nullOr package;
      description = "Package containing the FSBL firmware";
      default = null;
    };
  };

  config = {
    fwPackages = [ config.fsbl.package ];

    fsbl = {
      package = lib.mkDefault (
        pkgs.zynq-pkgs.fsbl {
          name = config.fsbl.name;
          version = config.fsbl.version;
          src = config.fsbl.src;
          stdenv = config.fsbl.stdenv;

          sdt = config.sdt.package;
          plat = config.plat;
          proc = config.fsbl.proc;
          extraPatches = config.fsbl.extraPatches;
        }
      );
    };
  };
}
