final: prev:
let
  meta = rec {
    baseName = "xilinx-lab";
    version = "2024.2_1113_1001";
    installTar = final.requireFile {
      name = "Vivado_Lab_Lin_${version}.tar";
      url = "https://www.xilinx.com/";
      hash = "sha256-2ONg2GWi9vbt7bK7NfpPiaJLM29Glot8/94oP2Rp+zg=";
    };
    installConfig = ./xilinx-pkgs/install-configs/xlnx-lab-2024-2.txt;
  };
in
{
  # Provide xilinx-unified-or-lab, if it does not already exist
  xilinx-unified-or-lab =
    if (prev ? xilinx-unified-or-lab) then prev.xilinx-unified-or-lab else final.xilinx-lab;

  xilinx-lab = final.xilinx-lab-utils.wrap {
    inputDerivation = final.xilinx-lab-unwrapped;
    extraTargetPkgs = pkgs: [ pkgs.libxcrypt-legacy ];
  };

  xilinx-lab-unwrapped = final.xilinx-lab-utils.install meta;

  xilinx-lab-utils = {
    genInstallConfig = final.callPackage ./xilinx-pkgs/install.nix {
      genInstallConfig = true;
    };

    install = final.callPackage ./xilinx-pkgs/install.nix { };
    wrap = final.callPackage ./xilinx-pkgs/wrap.nix { };
  };
}
