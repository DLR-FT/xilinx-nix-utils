final: prev:
let
  meta = rec {
    baseName = "xilinx-lab";
    version = "2025.2_1114_2157";
    installTar = final.requireFile {
      name = "Vivado_Lab_Lin_${version}.tar";
      url = "https://www.xilinx.com/";
      hash = "sha256-0w8YZFzYz7DfD/TM4GcwN5spKiXYF3UEDB5URVIdOv4=";
    };
    installConfig = ./xilinx-pkgs/install-configs/xlnx-lab-2025-2.txt;
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
