{
  config,
  lib,
  pkgs,
  ...
}:
{
  options.flash-qspi = {
    name = lib.mkOption {
      type = with lib.types; singleLineStr;
      description = "name";
      default = config.name + "-flash-qspi";
    };

    version = lib.mkOption {
      type = with lib.types; nullOr singleLineStr;
      description = "version";
      default = null;
    };

    flashPart = lib.mkOption {
      type = with lib.types; singleLineStr;
      description = ''
        Flash part e.g. mt25qu512-qspi-x4-single, ...
        Use program-flash.tcl -flash "" to get known flash parts
        See vivado tcl function "get_cfgmem_parts"
      '';
    };

    initFsbl = lib.mkOption {
      type = with lib.types; package;
      description = ''
        FSBL used for initializing the hw before flashing
        In most cases this can be the same as the fsbl in the boot image
        Only for Zynq7 devices which cannnot be physically switched into JTAG boot mode
        a modified FSBL is necessary.
        (https://adaptivesupport.amd.com/s/article/70548?language=en_US)
      '';
      default = config.fsbl.package;
    };

    offset = lib.mkOption {
      type = with lib.types; nullOr (either int singleLineStr);
      description = "Offset at which the image is flashed";
      default = null;
    };

    package = lib.mkOption {
      type = with lib.types; package;
      description = "Package containing the QSPI flash script.";
    };
  };

  config = {
    fwPackages = [ config.flash-qspi.package ];

    flash-qspi = {
      package = lib.mkDefault (
        pkgs.zynq-pkgs.flash-qspi {
          name = config.flash-qspi.name;
          version = config.flash-qspi.version;

          bootImage = config.boot-image.package;
          flashPart = config.flash-qspi.flashPart;
          initFsbl = config.flash-qspi.initFsbl;
          offset = config.flash-qspi.offset;
        }
      );
    };
  };
}
