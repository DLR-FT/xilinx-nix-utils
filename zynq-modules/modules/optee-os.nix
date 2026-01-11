{
  config,
  lib,
  pkgs,
  ...
}:
{
  options.optee-os = {
    enable = lib.mkEnableOption "Enable BL32 OPTEE-OS";

    name = lib.mkOption {
      type = with lib.types; singleLineStr;
      description = "name";
      default = config.name + "-optee-os";
    };

    version = lib.mkOption {
      type = with lib.types; nullOr singleLineStr;
      description = "version";
      default = null;
    };

    src = lib.mkOption {
      type = with lib.types; path;
      description = "OPTEE-OS source repo (github: xilinx/optee_os).";
      default = pkgs.zynq-srcs.optee-os-src;
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
      default =
        {
          "psu_cortexa53_0" = pkgs.pkgsCross.aarch64-multiplatform.stdenv;
        }
        .${config.optee-os.proc};
    };

    package = lib.mkOption {
      type = with lib.types; nullOr package;
      description = "Package containing the OPTEE-OS firmware.";
      default = null;
    };
  };

  config = lib.mkIf config.optee-os.enable {
    fwPackages = [ config.optee-os.package ];

    optee-os = {
      package = lib.mkDefault (
        pkgs.zynq-pkgs.optee-os {
          name = config.optee-os.name;
          version = config.optee-os.version;
          src = config.optee-os.src;
          stdenv = config.optee-os.stdenv;

          plat =
            {
              zynq7 = "zynq7k-zc702";
              zynqmp = "zynqmp-zcu102";
            }
            .${config.plat};

          extraMakeFlags = config.optee-os.extraMakeFlags;
          extraPatches = config.optee-os.extraPatches;
        }
      );
    };
  };
}
