{
  config,
  lib,
  pkgs,
  ...
}:
{
  options.boot-jtag = {
    enable = lib.mkEnableOption "Enable script for booting via JTAG.";

    name = lib.mkOption {
      type = with lib.types; singleLineStr;
      description = "name";
      default = config.name + "-boot-jtag";
    };

    version = lib.mkOption {
      type = with lib.types; nullOr singleLineStr;
      description = "version";
      default = null;
    };

    forceBootModeJtag = lib.mkOption {
      type = with lib.types; bool;
      description = "Switch ZynqMP boot mode to JTAG by software before downloading firmware.";
      default = false;
    };

    bit = lib.mkOption {
      type = with lib.types; nullOr path;
      description = "";
      default = null;
    };

    pmufw = lib.mkOption {
      type = with lib.types; nullOr path;
      description = "";
      default = null;
    };

    fsbl = lib.mkOption {
      type = with lib.types; nullOr path;
      description = "";
      default = null;
    };

    tfa = lib.mkOption {
      type = with lib.types; nullOr path;
      description = "";
      default = null;
    };

    dtb = lib.mkOption {
      type = with lib.types; nullOr path;
      description = "";
      default = null;
    };

    dtbAddr = lib.mkOption {
      type = with lib.types; nullOr (either int singleLineStr);
      description = null;
    };

    uboot = lib.mkOption {
      type = with lib.types; nullOr path;
      description = "";
      default = null;
    };

    package = lib.mkOption {
      type = with lib.types; package;
      description = "Package containing the JTAG boot script.";
    };
  };

  config = lib.mkIf config.boot-jtag.enable {
    fwPackages = [ config.boot-jtag.package ];

    boot-jtag = {
      package = lib.mkDefault (
        pkgs.zynq-pkgs.boot-jtag {
          name = config.boot-jtag.name;
          version = config.boot-jtag.version;

          plat = config.plat;
          forceBootModeJtag = config.boot-jtag.forceBootModeJtag;
          bit = config.boot-jtag.bit;
          pmufw = config.boot-jtag.pmufw;
          fsbl = config.boot-jtag.fsbl;
          tfa = config.boot-jtag.tfa;
          dtb = config.boot-jtag.dtb;
          dtbAddr = config.boot-jtag.dtbAddr;
          uboot = config.boot-jtag.uboot;
        }
      );
    };
  };
}
