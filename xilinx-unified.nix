final: prev: rec {
  xilinx-unified-unwrapped = final.xilinx-unified-2024-2-unwrapped;
  xilinx-unified = final.xilinx-unified-2024-2;

  xilinx-unified-2024-2-unwrapped = final.callPackage ./xilinx-unified/xilinx-unified.nix rec {
    name = "xilinx-unified";
    version = "2024.2_1113_1001";
    installTar = final.requireFile {
      name = "FPGAs_AdaptiveSoCs_Unified_${version}.tar";
      url = "https://www.xilinx.com/";
      hash = "sha256-l0+S90m9FeOMRdhwfEWznvkDgZMQ3Blryq+2brFsjzw=";
    };
    install_config = ./xilinx-unified/install-configs/xlnx-unified-2024-2.txt;
  };

  xilinx-unified-2024-2 = final.callPackage ./xilinx-unified/wrap-xilinx.nix {
    inputDerivation = final.xilinx-unified-2024-2-unwrapped;
  };

  xilinx-unified-2024-1-unwrapped = final.callPackage ./xilinx-unified/xilinx-unified.nix rec {
    name = "xilinx-unified";
    version = "2024.1_0522_2023";
    installTar = final.requireFile {
      name = "FPGAs_AdaptiveSoCs_Unified_${version}.tar.gz";
      url = "https://www.xilinx.com/";
      hash = "sha256-AH7MJNhTMnaCCENluF26orxVCiZU/RF9bNbaHAnH8QM=";
    };
    install_config = ./xilinx-unified/install-configs/xlnx-unified-2024-1.txt;
  };

  xilinx-unified-2024-1 = final.callPackage ./xilinx-unified/wrap-xilinx.nix {
    inputDerivation = final.xilinx-unified-2024-1-unwrapped;
  };

  xilinx-unified-2023-2-unwrapped = final.callPackage ./xilinx-unified/xilinx-unified.nix rec {
    name = "xilinx-unified";
    version = "2023.2_1013_2256";
    installTar = final.requireFile {
      name = "FPGAs_AdaptiveSoCs_Unified_${version}.tar.gz";
      url = "https://www.xilinx.com/";
      hash = "sha256-SCRztYAKux101RudvueXp19EPUBfxGqQMfMMIBa2r6o=";
    };
  };

  xilinx-unified-2023-2 = final.callPackage ./xilinx-unified/wrap-xilinx.nix {
    inputDerivation = final.xilinx-unified-2023-2-unwrapped;
  };

  xilinx-unified-2023-1-unwrapped = final.callPackage ./xilinx-unified/xilinx-unified.nix rec {
    pname = "xilinx-unified";
    version = "2023.1_0507_1903";
    installTar = final.requireFile {
      name = "Xilinx_Unified_${version}.tar.gz";
      url = "https://www.xilinx.com/";
      hash = "sha256-Kq7GwlDvdTP+X3+u1bjQUkcy7+7FNFnbOiIJXF87nDk=";
    };
  };

  xilinx-unified-2023-1 = final.callPackage ./xilinx-unified/wrap-xilinx.nix {
    inputDerivation = final.xilinx-unified-2023-1-unwrapped;
  };

  xilinx-vivado-2019-2-unwrapped = final.callPackage ./xilinx-unified/xilinx-unified.nix rec {
    pname = "xilinx-vivado";
    version = "2019.2_1106_2127";
    installTar = final.requireFile {
      name = "Xilinx_Vivado_${version}.tar.gz";
      url = "https://www.xilinx.com/";
      hash = "sha256-sGeBz7KUW6lI8Eo1nobWZmxkK+d2VidnxZ91FcqaDpY=";
    };
    agreements = [
      "XilinxEULA"
      "3rdPartyEULA"
      "WebTalkTerms"
    ];
  };

  xilinx-vivado-2019-2 = final.callPackage ./xilinx-unified/wrap-xilinx.nix {
    inputDerivation = final.xilinx-vivado-2019-2-unwrapped;
  };

  xilinx-common = xilinx-unified;

  genXilinxFhs = final.callPackage ./xilinx-unified/xilinx-fhs.nix { };
}
