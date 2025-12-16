final: prev:
let
  meta = rec {
    baseName = "xilinx-unified";
    version = "2024.2_1113_1001";
    installTar = final.requireFile {
      name = "FPGAs_AdaptiveSoCs_Unified_${version}.tar";
      url = "https://www.xilinx.com/";
      hash = "sha256-l0+S90m9FeOMRdhwfEWznvkDgZMQ3Blryq+2brFsjzw=";
    };
    installConfig = ./xilinx-pkgs/install-configs/xlnx-unified-2024-2.txt;
  };
in
{
  # Provides xilinx-unified, or xilinx-lab, depending on which overlays are loaded.
  # Prioritizes always xilinx-unified, independently of the overlay order.
  xilinx-unified-or-lab = final.xilinx-unified;

  xilinx-unified = final.xilinx-unified-utils.wrap {
    inputDerivation = final.xilinx-unified-unwrapped;
    extraTargetPkgs = pkgs: [ pkgs.libxcrypt-legacy ];
  };

  install-config = final.xilinx-unified-utils.genInstallConfig meta;

  xilinx-unified-unwrapped = final.xilinx-unified-utils.install meta;

  xilinx-unified-utils = {
    genInstallConfig = final.callPackage ./xilinx-pkgs/install.nix {
      genInstallConfig = true;
    };

    install = final.callPackage ./xilinx-pkgs/install.nix { };
    wrap = final.callPackage ./xilinx-pkgs/wrap.nix { };
  };
}
