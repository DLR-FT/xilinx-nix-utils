{
  config,
  lib,
  pkgs,
  ...
}:
{
  options.flash-qspi = {
    enable = lib.mkEnableOption "Enable script for QSPI flashing.";

    name = lib.mkOption {
      type = with lib.types; strMatching "[a-zA-Z0-9_-]+";
      description = "name";
      default = config.name + "-flash-qspi";
    };

    version = lib.mkOption {
      type = with lib.types; nullOr singleLineStr;
      description = "version";
      default = null;
    };

    bootImages = lib.mkOption {
      type = with lib.types; either path (listOf path);
      description = ''
        Specifies the boot-image(s) to be flashed.
        Can be either a single image or two images for a dual flash configurations.'';
    };

    initFsbl = lib.mkOption {
      type = with lib.types; path;
      description = ''
        Specifies the first-stage bootloader (FSBL) used for initializing the hardware
        before flashing. In most cases this can be the same as the FSBL in the boot image itself.
        Only for Zynq7 devices which cannnot be physically switched into JTAG boot mode
        a modified FSBL is necessary.
        (https://adaptivesupport.amd.com/s/article/70548?language=en_US)
      '';
    };

    flashPart = lib.mkOption {
      type = with lib.types; singleLineStr;
      description = ''
        Flash part / configuration e.g. mt25qu512-qspi-x4-single, ... to flash.
        Use program-flash.sh -flash_part "*" for a list of known flash parts.
      '';
    };

    offset = lib.mkOption {
      type = with lib.types; nullOr (either int singleLineStr);
      description = "Offset at which the image is flashed.";
      default = null;
    };

    package = lib.mkOption {
      type = with lib.types; package;
      description = "Package containing the QSPI flash script.";
    };
  };

  config = lib.mkIf config.flash-qspi.enable {
    fwPackages = [ config.flash-qspi.package ];

    flash-qspi = {
      package = lib.mkDefault (
        pkgs.zynq-pkgs.flash-qspi {
          name = config.flash-qspi.name;
          version = config.flash-qspi.version;

          bootImages = config.flash-qspi.bootImages;
          initFsbl = config.flash-qspi.initFsbl;
          flashPart = config.flash-qspi.flashPart;
          offset = config.flash-qspi.offset;
        }
      );
    };
  };
}
