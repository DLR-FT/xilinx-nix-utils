final: prev: {
  zynq-utils = {
    hwplat = prev.callPackage ./zynq-utils/hwplat.nix { };
    sdt = prev.callPackage ./zynq-utils/sdt.nix { };
    pmufw = prev.callPackage ./zynq-utils/pmufw.nix { };
    fsbl = prev.callPackage ./zynq-utils/fsbl.nix { };
    tfa = prev.callPackage ./zynq-utils/tfa.nix { };

    linux-dt = prev.callPackage ./zynq-utils/linux-dt.nix { };
    uboot = prev.callPackage ./zynq-utils/uboot.nix { };

    zynq7 = {
      boot-image = prev.callPackage ./zynq-utils/zynq7/boot-image.nix { };
      board = prev.callPackage ./zynq-utils/zynq7/board.nix { };

      boot-jtag = prev.callPackage ./zynq-utils/zynq7/boot-jtag.nix { };
    };

    zynqmp = {
      boot-image = prev.callPackage ./zynq-utils/zynqmp/boot-image.nix { };
      board = prev.callPackage ./zynq-utils/zynqmp/board.nix { };

      boot-jtag = prev.callPackage ./zynq-utils/zynqmp/boot-jtag.nix { };
    };

    flash-qspi = prev.callPackage ./zynq-utils/flash-qspi.nix { };

    python-lopper = prev.python3Packages.callPackage ./zynq-utils/python-lopper.nix { };
  };
}
