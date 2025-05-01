final: prev: {
  zynq-utils = {
    hwplat = prev.callPackage ./zynq-utils/hwplat.nix { };
    sdt = prev.callPackage ./zynq-utils/sdt.nix { };
    pmufw = prev.callPackage ./zynq-utils/pmufw.nix { };
    fsbl = prev.callPackage ./zynq-utils/fsbl.nix { };
    tfa = prev.callPackage ./zynq-utils/tfa.nix { };

    linux-dt = prev.callPackage ./zynq-utils/linux-dt.nix { };
    uboot = prev.callPackage ./zynq-utils/uboot.nix { };

    boot-image = prev.callPackage ./zynq-utils/boot-image.nix { };

    boot-jtag-cmd = prev.callPackage ./zynq-utils/boot-jtag-cmd.nix { };
    flash-qspi-cmd = prev.callPackage ./zynq-utils/flash-qspi-cmd.nix { };

    zynqmp-board = prev.callPackage ./zynq-utils/zynqmp-board.nix { };

    python-lopper = prev.python3Packages.callPackage ./zynq-utils/python-lopper.nix { };

    embeddedsw-src = prev.fetchFromGitHub {
      owner = "Xilinx";
      repo = "embeddedsw";
      rev = "xilinx_v2024.2";
      hash = "sha256-j2wY1XQ4TFGZpDcORXDwDpXSUEnAnl8TcBeA2y9bln4=";
    };

    sdt-src = prev.fetchFromGitHub {
      owner = "Xilinx";
      repo = "system-device-tree-xlnx";
      rev = "xilinx_v2024.2";
      hash = "sha256-tc6YU+yXZ8LZ2Sizo7jzNsyGpj6eLTefYQl0AfMJ68Q=";
    };

    tfa-src = prev.fetchFromGitHub {
      owner = "Xilinx";
      repo = "arm-trusted-firmware";
      rev = "xilinx-v2024.2";
      hash = "sha256-bq9Da3Zc+soEudJxXRejehordtttXJ3vayYZb5IfJFI=";
    };

    uboot-src = prev.fetchFromGitHub {
      owner = "Xilinx";
      repo = "u-boot-xlnx";
      rev = "xilinx-v2024.2";
      hash = "sha256-qeyvbpDvgg3Uu9Rr7yQIzIMhbLxGIuSAc/T95GPMDL8=";
    };

    lopper-src = prev.fetchFromGitHub {
      owner = "devicetree-org";
      repo = "lopper";
      rev = "v0.2024.x";
      hash = "sha256-saK6Mt3sCf6xJVDnjqVrasswVocSwvfVdTMw0fx7bdA=";
    };
  };
}
