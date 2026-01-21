{
  zynq-modules,
}:
zynq-modules.mkZynqFirmware {
  modules = [
    (
      { lib, ... }:
      {
        config = {
          name = lib.mkDefault "kria-kr260";

          plat = "zynqmp";

          hwplat.src = lib.mkDefault ./vivado-srcs;

          sdt.boardDts = lib.mkDefault "zynqmp-sck-kr-g-revb";

          linux-dt = {
            extraLops = [
              "./lopper/lops/lop-a53-imux.dts"
            ];
            extraDtsi = [ ./dts/board.dtsi ];
          };

          tfa.extraMakeFlags = lib.mkBefore [ "ZYNQMP_CONSOLE=cadence1" ];

          uboot.extraConfigs = lib.mkBefore [
            "CONFIG_ENV_IS_NOWHERE=n"
            "CONFIG_ENV_IS_IN_FAT=n"
            "CONFIG_ENV_IS_IN_NAND=n"
            "CONFIG_ENV_SIZE=0x20000"
            "CONFIG_ENV_SECT_SIZE=0x20000"
            "CONFIG_ENV_OFFSET=0x2200000"
            "CONFIG_ENV_OFFSET_REDUND=0x2220000"

            "CONFIG_TFTP_PORT=y"

            "CONFIG_USB_ONBOARD_HUB=y"

            "CONFIG_LOG=y"
            "CONFIG_CMD_LOG=y"
            "CONFIG_LOG_DEFAULT_LEVEL=4"
            "CONFIG_LOG_MAX_LEVEL=7"
            "CONFIG_LOG_CONSOLE=y"
          ];

          boot-jtag.forceBootModeJtag = true;

          flash-qspi = {
            flashPart = "mt25qu512-qspi-x4-single";
            offset = lib.mkDefault "0x00200000";
          };
        };
      }
    )
  ];
}
