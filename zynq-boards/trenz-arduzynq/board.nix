{
  zynq-modules,
}:
zynq-modules.mkZynqFirmware {
  modules = [
    (
      { config, lib, ... }:
      let
        init-fsbl = config.fsbl.package.overrideAttrs (
          final: prev: {
            name = prev.name + "-flash-qspi-patched";
            patches = [ ./patches/fsbl-flash-qspi.patch ];
          }
        );
      in
      {
        name = lib.mkDefault "trenz-arduzynq";
        description = lib.mkDefault "Base Firmware for the Trenz ArduZynq (TE0723-03-41C64-A).";

        plat = "zynq7";

        hwplat.src = lib.mkDefault ./vivado-srcs;

        uboot.extraConfigs = lib.mkBefore [
          "CONFIG_LOG=y"
          "CONFIG_CMD_LOG=y"
          "CONFIG_LOG_DEFAULT_LEVEL=4"
          "CONFIG_LOG_MAX_LEVEL=7"
          "CONFIG_LOG_CONSOLE=y"
        ];

        flash-qspi.initFsbl = init-fsbl.elf;
        fwPackages = [ init-fsbl ];

        flash-qspi.flashPart = lib.mkDefault "s25fl127s-3.3v-qspi-x4-single";
      }
    )
  ];
}
