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
      type = with lib.types; strMatching "[a-zA-Z0-9_-]+";
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
      description = ''
        Specifies the bitstream file to download.
        Can be null to skip bitstream loading.'';
      default = null;
    };

    pmufw = lib.mkOption {
      type = with lib.types; nullOr path;
      description = ''
        Specifies the PMU firmware to download and run (ZynqMP only).
        Can be null to skip PMU firmware download and run.'';
      default = null;
    };

    fsbl = lib.mkOption {
      type = with lib.types; nullOr path;
      description = ''
        Specifies the first-stage bootloader (FSBL) firmware to download and run.
        Can be null to skip FSBL download and run.'';
      default = null;
    };

    tfa = lib.mkOption {
      type = with lib.types; nullOr path;
      description = ''
        Specifies the Trusted Firmware-A to download and run (ZynqMP only).
        Can be null to skip Trusted Firmware-A download and run.'';
      default = null;
    };

    dtb = lib.mkOption {
      type = with lib.types; nullOr path;
      description = ''
        Specifies the device-tree binary to download.
        Can be null to skip device-tree download.'';
      default = null;
    };

    dtbAddr = lib.mkOption {
      type = with lib.types; nullOr (either int singleLineStr);
      description = "Specifies the address at which the device-tree will be loaded.";
      default = "0x00100000";
    };

    uboot = lib.mkOption {
      type = with lib.types; nullOr path;
      description = ''
        Specifies the U-Boot firmware to download and run.
        Can be null to skip U-Boot download and run.'';
      default = null;
    };

    package = lib.mkOption {
      type = with lib.types; package;
      description = "Package containing the generated JTAG boot script.";
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
