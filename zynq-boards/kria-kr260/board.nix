{
  zynq-modules,
}:
zynq-modules.mkZynqFirmware {
  modules = [
    (
      { lib, ... }:
      {
        name = lib.mkDefault "kria-k260";
        description = lib.mkDefault "Base Firmware for the Kria KR260 Robotics Starter Kit";

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

        flash-qspi = lib.mkDefault {
          flashPart = "mt25qu512-qspi-x4-single";
          offset = "0x00200000";
        };
      }
    )
  ];
}
