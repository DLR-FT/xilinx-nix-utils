{
  zynq-utils,
}:
zynq-utils.zynqmp.board {
  name = "te0706-0821-3be21";

  hwplat = {
    src = ./vivado-srcs;
  };

  linux-dt = {
    extraLops = [
      "./lopper/lops/lop-a53-imux.dts"
    ];
    extraDtsi = [ ./dts/board.dtsi ];
  };

  uboot = {
    extraConfig = ''
      CONFIG_ENV_IS_NOWHERE=n
      CONFIG_ENV_IS_IN_FAT=n
      CONFIG_ENV_IS_IN_NAND=n

      CONFIG_TFTP_PORT=y

      CONFIG_LOG=y
      CONFIG_CMD_LOG=y
      CONFIG_LOG_DEFAULT_LEVEL=4
      CONFIG_LOG_MAX_LEVEL=7
      CONFIG_LOG_CONSOLE=y
    '';
  };

  boot-image = {
    dualQspiMode = "parallel";
  };

  boot-jtag = {
    forceBootModeJtag = true;
  };

  flash-qspi = {
    flashPart = "mt25qu512-qspi-x8-parallel";
  };
}
