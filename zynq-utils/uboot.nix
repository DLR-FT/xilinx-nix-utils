{
  lib,
  buildUBoot,
  fetchFromGitHub,
}:

{
  extraConfig ? "",
  extraEnv ? { },
  boot2el2 ? true,
  uboot-src ? fetchFromGitHub {
    owner = "Xilinx";
    repo = "u-boot-xlnx";
    rev = "xlnx_rebase_v2024.01_2024.1";
    hash = "sha256-G6GOcazwY4A/muG2hh4pj8i9jm536kYhirrOzcn77WE=";
  },
}:
(buildUBoot {
  extraMeta.platforms = [ "aarch64-linux" ];
  defconfig = "xilinx_zynqmp_virt_defconfig";

  inherit extraConfig;

  env = extraEnv;

  # The `DEVICE_TREE` environment variable must only be propagated __after__ the initial
  # `make xilinx_zynqmp_virt_defconfig` call.

  preInstall = ''
    export DEVICE_TREE="zynqmp-zcu102-rev1.0"
  '';
  filesToInstall = [
    "spl/boot.bin"
    "u-boot.elf"
    "u-boot.img"
    ".config"
  ];
  version = "${uboot-src.rev}";
  dontPatch = true; # avoid unapplicable raspberrypi patches

  # u-boot-xlnx ignores the CONFIG_ARMV8_SWITCH_TO_EL1 macro, and always unconditionally
  # boots into EL1 when doing `go`. This little patch changes that behavior to stay in
  # EL2, so that seL4 can happily boot even in hypervisor mode.
  prePatch = lib.strings.optionalString boot2el2 ''
    substituteInPlace board/xilinx/zynqmp/zynqmp.c \
      --replace armv8_switch_to_el1 armv8_switch_to_el2
  '';
}).overrideAttrs
  (
    final: prev: {
      src = uboot-src;
      passthru = {
        elf = "${final.finalPackage.out}/u-boot.elf";
      };
    }
  )
