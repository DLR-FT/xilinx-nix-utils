final: prev:
let
  meta = rec {
    baseName = "xilinx-lab";
    version = "2025.1_0530_0145";
    installTar = final.requireFile {
      name = "Vivado_Lab_Lin_${version}.tar";
      url = "https://www.xilinx.com/";
      hash = "sha256-2VogZ3cb1nUNu0Nv20NVuxTZJp9fwkwAZbTJG8av86k=";
    };
    installConfig = ./xilinx-pkgs/install-configs/xlnx-lab-2025-1.txt;
  };
in
{
  # Provide xilinx-unified-or-lab, if it does not already exist
  xilinx-unified-or-lab =
    if (prev ? xilinx-unified-or-lab) then prev.xilinx-unified-or-lab else final.xilinx-lab;

  xilinx-lab = final.xilinx-lab-utils.wrap {
    inputDerivation = final.xilinx-lab-unwrapped;
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
