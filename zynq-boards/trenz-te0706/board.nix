{
  zynq-modules,
}:
zynq-modules.mkZynqFirmware {
  modules = [
    (
      { lib, ... }:
      {
        name = lib.mkDefault "trenz-te0706";
        description = lib.mkDefault "Base Firmware for the Trenz TE0706 Base Board with the 3EG ZynqMP with 2GB RAM (TE0821-3BE21)";

        plat = "zynqmp";

        hwplat.src = lib.mkDefault ./vivado-srcs;

        linux-dt = {
          extraLops = [
            "./lopper/lops/lop-a53-imux.dts"
          ];
          extraDtsi = [ ./dts/board.dtsi ];
        };

        uboot.extraConfigs = lib.mkBefore [
          "CONFIG_ENV_IS_NOWHERE=n"
          "CONFIG_ENV_IS_IN_FAT=n"
          "CONFIG_ENV_IS_IN_NAND=n"

          "CONFIG_TFTP_PORT=y"

          "CONFIG_LOG=y"
          "CONFIG_CMD_LOG=y"
          "CONFIG_LOG_DEFAULT_LEVEL=4"
          "CONFIG_LOG_MAX_LEVEL=7"
          "CONFIG_LOG_CONSOLE=y"
        ];

        # todo: does not work
        # boot-image.dualQspiMode = lib.mkDefault "parallel";

        flash-qspi.flashPart = lib.mkDefault "mt25qu512-qspi-x8-dual_parallel";
      }
    )
  ];
}
