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

    python-lopper = prev.python3Packages.callPackage ./zynq-utils/python-lopper.nix { };

    embeddedsw-src = prev.fetchFromGitHub {
      owner = "Xilinx";
      repo = "embeddedsw";
      rev = "xilinx_v2024.1";
      hash = "sha256-vh7tdHNd3miDZplTiRP8UWhQ/HLrjMcbQXCJjTO4p9o=";
    };

    dt-src = prev.fetchFromGitHub {
      owner = "Xilinx";
      repo = "device-tree-xlnx";
      rev = "xilinx_v2024.1";
      hash = "sha256-dja+JwbXwiBRJwg/6GNOdONp/vrihmfPBnpjEA/xxnk=";
    };

    tfa-src = prev.fetchFromGitHub {
      owner = "Xilinx";
      repo = "arm-trusted-firmware";
      rev = "xilinx-v2024.1";
      hash = "sha256-XEFHS2hZWdJEB7b0Zdci/PtNc7csn+zQWljiG9Tx0mM=";
    };

    uboot-src = prev.fetchFromGitHub {
      owner = "Xilinx";
      repo = "u-boot-xlnx";
      rev = "xlnx_rebase_v2024.01_2024.1";
      hash = "sha256-G6GOcazwY4A/muG2hh4pj8i9jm536kYhirrOzcn77WE=";
    };

    lopper-src = prev.fetchFromGitHub {
      owner = "devicetree-org";
      repo = "lopper";
      rev = "fcfad5150f98691e2a867c76d3f60f3631a3fd59";
      hash = "sha256-3Jt47POX5avx1OzUhkniov3BLcrmQ+ivK/fORzcOT04=";
    };
  };
}
