final: prev: {
  zynq-pkgs = {
    bootgen = prev.callPackage ./zynq-pkgs/bootgen.nix { };

    hwplat = prev.callPackage ./zynq-pkgs/hwplat.nix { };
    sdt = prev.callPackage ./zynq-pkgs/sdt.nix { };
    pmufw = prev.callPackage ./zynq-pkgs/pmufw.nix { };
    fsbl = prev.callPackage ./zynq-pkgs/fsbl.nix { };
    tfa = prev.callPackage ./zynq-pkgs/tfa.nix { };

    linux-dt = prev.callPackage ./zynq-pkgs/linux-dt.nix { };
    uboot = prev.callPackage ./zynq-pkgs/uboot.nix { };

    boot-image = prev.callPackage ./zynq-pkgs/boot-image.nix { };

    flash-qspi = prev.callPackage ./zynq-pkgs/flash-qspi.nix { };

    zynq7 = {
      board = prev.callPackage ./zynq-pkgs/zynq7/board.nix { };
      boot-jtag = prev.callPackage ./zynq-pkgs/zynq7/boot-jtag.nix { };
    };

    zynqmp = {
      board = prev.callPackage ./zynq-pkgs/zynqmp/board.nix { };
      boot-jtag = prev.callPackage ./zynq-pkgs/zynqmp/boot-jtag.nix { };
    };

    python-lopper = prev.python3Packages.callPackage ./zynq-pkgs/python-lopper.nix { };
  };
}
