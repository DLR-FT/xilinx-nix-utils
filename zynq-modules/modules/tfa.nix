{
  config,
  lib,
  pkgs,
  ...
}:
{
  options.tfa = {
    enable = lib.mkEnableOption "Enable BL31 Trusted Firmware-A build.";

    name = lib.mkOption {
      type = with lib.types; strMatching "[a-zA-Z0-9_-]+";
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
      description = "Specified the Trusted-Firmware-A source repo (e.g. github:xilinx/arm-trusted-firmware).";
      default = pkgs.zynq-srcs.tfa-src;
    };

    plat = lib.mkOption {
      type = with lib.types; singleLineStr;
      description = "Specifies the TF-A build platform (zynqmp, ...).";
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
      description = "Specifies the stdenv toolchain used to build the TF-A firmware.";
    };

    package = lib.mkOption {
      type = with lib.types; package;
      description = "Package containing the build TF-A firmware.";
    };
  };

  config = lib.mkIf config.tfa.enable {
    fwPackages = [ config.tfa.package ];

    tfa = {
      plat = lib.mkDefault (
        {
          zynqmp = "zynqmp";
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
        pkgs.zynq-pkgs.tfa {
          name = config.tfa.name;
          version = config.tfa.version;
          src = config.tfa.src;
          stdenv = config.tfa.stdenv;

          plat = config.tfa.plat;
          extraMakeFlags = config.tfa.extraMakeFlags;
          extraPatches = config.tfa.extraPatches;
        }
      );
    };

    uboot.bl31 = lib.mkDefault config.tfa.package.elf;
    boot-image.partitions.tfa = {
      order = 400;
      options = {
        trustzone = true;
        exception_level = lib.mkIf (config.plat == "zynqmp") (lib.mkDefault "el-3");
      };
      file = config.tfa.package.elf;
    };
    boot-jtag.tfa = lib.mkDefault config.tfa.package.elf;
  };
}
