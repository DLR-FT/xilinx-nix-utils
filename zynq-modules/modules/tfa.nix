{
  config,
  lib,
  pkgs,
  ...
}:
{
  options.tfa = {
    name = lib.mkOption {
      type = with lib.types; singleLineStr;
      description = "name";
      default = config.name + "-tfa";
    };

    version = lib.mkOption {
      type = with lib.types; nullOr singleLineStr;
      description = "version";
      default = null;
    };

    src = lib.mkOption {
      type = with lib.types; path;
      description = "Trusted-Firmware-A source repo (github: xilinx/arm-trusted-firmware).";
      default = pkgs.zynq-srcs.tfa-src;
    };

    proc = lib.mkOption {
      type = with lib.types; singleLineStr;
      description = "Zynq processor id (ps7_cortexa9_0, psu_cortexa53_0, psu_pmu_0, ...).";
      default = { zynqmp = "psu_cortexa53_0"; }.${config.plat};
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
      description = "stdenv used to build the TF-A firmware.";
      default = { "psu_cortexa53_0" = pkgs.pkgsCross.aarch64-multiplatform.stdenv; }.${config.tfa.proc};
    };

    package = lib.mkOption {
      type = with lib.types; nullOr package;
      description = "Package containing the TF-A firmware.";
      default = null;
    };
  };

  config = {
    fwPackages = [ config.tfa.package ];

    tfa = {
      package = lib.mkDefault (
        pkgs.zynq-pkgs.tfa {
          name = config.tfa.name;
          version = config.tfa.version;
          src = config.tfa.src;
          stdenv = config.tfa.stdenv;

          plat = config.plat;
          extraMakeFlags = config.tfa.extraMakeFlags;
          extraPatches = config.tfa.extraPatches;
        }
      );
    };
  };
}
