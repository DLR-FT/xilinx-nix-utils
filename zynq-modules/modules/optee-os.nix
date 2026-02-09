{
  config,
  lib,
  pkgs,
  ...
}:
{
  options.optee-os = {
    enable = lib.mkEnableOption "Enable BL32 OPTEE-OS build.";

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

    plat = lib.mkOption {
      type = with lib.types; singleLineStr;
      description = "OPTEE-OS build platform (zynq7k-zc702, zynqmp-zcu102, ...).";
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
      default = pkgs.pkgsCross.aarch64-multiplatform.stdenv;
    };

    package = lib.mkOption {
      type = with lib.types; package;
      description = "Package containing the OPTEE-OS firmware.";
    };
  };

  config = lib.mkIf config.optee-os.enable {
    fwPackages = [ config.optee-os.package ];

    optee-os = {
      plat = lib.mkDefault (
        {
          zynq7 = "zynq7k-zc702";
          zynqmp = "zynqmp-zcu102";
        }
        .${config.plat}
      );

      stdenv = lib.mkDefault (
        {
          zynqmp = pkgs.pkgsCross.aarch64-multiplatform.stdenv;
        }
        .${config.plat}
      );

      package = lib.mkDefault (
        pkgs.zynq-pkgs.optee-os {
          name = config.optee-os.name;
          version = config.optee-os.version;
          src = config.optee-os.src;
          stdenv = config.optee-os.stdenv;

          plat = config.optee-os.plat;
          extraMakeFlags = config.optee-os.extraMakeFlags;
          extraPatches = config.optee-os.extraPatches;
        }
      );
    };

    uboot.tee = lib.mkDefault config.optee-os.package.elf;
    boot-image.partitions.optee-os = {
      order = 500;
      options = {
        trustzone = true;
        exception_level = lib.mkIf (config.plat == "zynqmp") (lib.mkDefault "el-1");
      };
      file = config.optee-os.package.elf;
    };
  };
}
