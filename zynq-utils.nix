final: prev: {
  zynqmp-utils = {
    hw = prev.callPackage ./zynq-utils/hw.nix { };
    sdt = prev.callPackage ./zynq-utils/sdt.nix { };
    pmufw = prev.callPackage ./zynq-utils/pmufw.nix { };
    fsbl = prev.callPackage ./zynq-utils/fsbl.nix { };
    atf = prev.callPackage ./zynq-utils/atf.nix { };
    uboot = prev.callPackage ./zynq-utils/uboot.nix { };

    boot-image = prev.callPackage ./zynq-utils/boot-image.nix { };

    boot-jtag-cmd = prev.callPackage ./zynq-utils/boot-jtag-cmd.nix { };
    flash-qspi-cmd = prev.callPackage ./zynq-utils/flash-qspi-cmd.nix { };

    python-lopper = prev.python3Packages.callPackage ./zynq-utils/lopper.nix { };
  };
}
