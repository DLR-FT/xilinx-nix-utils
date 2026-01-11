{
  config,
  lib,
  pkgs,
  ...
}:
{
  options.boot-jtag = {
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

    dtbLoadAddr = lib.mkOption {
      type = with lib.types; either int singleLineStr;
      description = "Load address of the dtb.";
      default =
        {
          zynq7 = "0x00100000";
          zynqmp = "0x00100000";
        }
        .${config.plat};
    };

    forceBootModeJtag = lib.mkOption {
      type = with lib.types; bool;
      description = "Switch Zynq boot mode to JTAG by software before downloading firmware.";
      default = false;
    };

    package = lib.mkOption {
      type = with lib.types; package;
      description = "Package containing the JTAG boot script.";
    };
  };

  config = {
    fwPackages = [ config.boot-jtag.package ];

    boot-jtag = {
      package = lib.mkDefault (
        {
          zynq7 = pkgs.zynq-pkgs.zynq7.boot-jtag {
            name = config.boot-jtag.name;
            version = config.boot-jtag.version;

            hwplat = config.hwplat.package;
            fsbl = config.fsbl.package;
            uboot = config.uboot.package;

            dtbLoadAddr = config.boot-jtag.dtbLoadAddr;
          };

          zynqmp = pkgs.zynq-pkgs.zynqmp.boot-jtag {
            name = config.boot-jtag.name;
            version = config.boot-jtag.version;

            hwplat = config.hwplat.package;
            pmufw = config.pmufw.package;
            fsbl = config.fsbl.package;
            tfa = config.tfa.package;
            uboot = config.uboot.package;

            dtbLoadAddr = config.boot-jtag.dtbLoadAddr;
            forceBootModeJtag = config.boot-jtag.forceBootModeJtag;
          };
        }
        .${config.plat}
      );
    };
  };
}
