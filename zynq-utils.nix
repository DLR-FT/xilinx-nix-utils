final: prev: {
  zynq-utils = {
    hwplat = prev.callPackage ./zynq-utils/hwplat.nix { };
    sdt = prev.callPackage ./zynq-utils/sdt.nix { };
    pmufw = prev.callPackage ./zynq-utils/pmufw.nix { };
    fsbl = prev.callPackage ./zynq-utils/fsbl.nix { };
    tfa = prev.callPackage ./zynq-utils/tfa.nix { };
    uboot = prev.callPackage ./zynq-utils/uboot.nix { };

    boot-image = prev.callPackage ./zynq-utils/boot-image.nix { };

    boot-jtag-cmd = prev.callPackage ./zynq-utils/boot-jtag-cmd.nix { };
    flash-qspi-cmd = prev.callPackage ./zynq-utils/flash-qspi-cmd.nix { };

    python-lopper = prev.python3Packages.callPackage ./zynq-utils/lopper.nix { };
  };
}
