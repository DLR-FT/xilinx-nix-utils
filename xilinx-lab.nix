final: prev: rec {
  xilinx-lab-unwrapped = final.xilinx-lab-2024-2-unwrapped;
  xilinx-lab = final.xilinx-lab-2024-2;

  xilinx-lab-2024-2-unwrapped = final.callPackage ./xilinx-unified/xilinx-unified.nix rec {
    name = "xilinx-lab";
    version = "2024.2_1113_1001";
    installTar = final.requireFile {
      name = "Vivado_Lab_Lin_${version}.tar";
      url = "https://www.xilinx.com/";
      hash = "sha256-2ONg2GWi9vbt7bK7NfpPiaJLM29Glot8/94oP2Rp+zg=";
    };
    install_config = null;
  };

  xilinx-lab-2024-2 = final.callPackage ./xilinx-unified/wrap-xilinx.nix {
    inputDerivation = final.xilinx-lab-2024-2-unwrapped;
  };

  # Provide xilinx-common, if it does not already exist
  xilinx-common = if (prev ? xilinx-common) then prev.xilinx-common else xilinx-lab;
}
