{
  zynq-utils,
}:
zynq-utils.zynqmp-board {
  name = "te0706-0821-3be21";
  src = ./vivado-srcs;

  sdt = {
    extraDtsi = ./dts/qspi-nor-flash.dtsi;
  };

  uboot = {
    extraConfig = ''
      # Workaround: "u-boot-spl.bin exceeds file size limit";
      CONFIG_SPL_SIZE_LIMIT=0x30000

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

  boot-jtag-cmd = {
    forceBootModeJtag = true;
  };

  flash-qspi-cmd = {
    flashType = "qspi-x8-dual_parallel";
    flashDensity = 128;
  };
}
