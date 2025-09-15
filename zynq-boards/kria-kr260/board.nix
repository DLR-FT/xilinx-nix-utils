{
  zynq-pkgs,
}:
zynq-pkgs.zynqmp.board {
  name = "kria-kr260";

  hwplat = {
    src = ./vivado-srcs;
  };

  sdt = {
    boardDts = "zynqmp-smk-k26-reva";
  };

  linux-dt = {
    extraLops = [
      "./lopper/lops/lop-a53-imux.dts"
    ];
  };

  tfa.extraMakeFlags = [ "ZYNQMP_CONSOLE=cadence1" ];

  uboot = {
    extraConfig = ''
      CONFIG_ENV_IS_NOWHERE=n
      CONFIG_ENV_IS_IN_FAT=n
      CONFIG_ENV_IS_IN_NAND=n
      CONFIG_ENV_SIZE=0x20000
      CONFIG_ENV_SECT_SIZE=0x20000
      CONFIG_ENV_OFFSET=0x2200000
      CONFIG_ENV_OFFSET_REDUND=0x2220000

      CONFIG_USB_ONBOARD_HUB=y

      CONFIG_LOG=y
      CONFIG_CMD_LOG=y
      CONFIG_LOG_DEFAULT_LEVEL=4
      CONFIG_LOG_MAX_LEVEL=7
      CONFIG_LOG_CONSOLE=y
    '';
  };

  boot-jtag = {
    forceBootModeJtag = true;
  };

  flash-qspi = {
    flashPart = "mt25qu512-qspi-x4-single";
    offset = "0x00200000";
  };
}
