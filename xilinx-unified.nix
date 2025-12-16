final: prev:
let
  meta = rec {
    baseName = "xilinx-unified";
    version = "2025.1_0530_0145";
    installTar = final.requireFile {
      name = "FPGAs_AdaptiveSoCs_Unified_SDI_${version}.tar";
      url = "https://www.xilinx.com/";
      hash = "sha256-9LASrgJAzRczREYpaXxg9qwVmP9SwMYDwrUyWK1SMqw=";
    };
    installConfig = ./xilinx-pkgs/install-configs/xlnx-unified-2025-1.txt;
  };
in
{
  # Provides xilinx-unified, or xilinx-lab, depending on which overlays are loaded.
  # Prioritizes always xilinx-unified, independently of the overlay order.
  xilinx-unified-or-lab = final.xilinx-unified;

  xilinx-unified = final.xilinx-unified-utils.wrap {
    inputDerivation = final.xilinx-unified-unwrapped;
  };

  xilinx-unified-unwrapped = final.xilinx-unified-utils.install meta;

  xilinx-unified-utils = {
    genInstallConfig = final.callPackage ./xilinx-pkgs/install.nix {
      genInstallConfig = true;
    };

    install = final.callPackage ./xilinx-pkgs/install.nix { };
    wrap = final.callPackage ./xilinx-pkgs/wrap.nix { };
  };
}
