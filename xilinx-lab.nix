final: prev: rec {
  xilinx-lab = final.xilinx-lab-versions.latest.xilinx-lab;

  # Provide xilinx-unified-or-lab, if it does not already exist
  xilinx-unified-or-lab =
    if (prev ? xilinx-unified-or-lab) then prev.xilinx-unified-or-lab else xilinx-lab;

  xilinx-lab-versions = {
    latest = final.xilinx-lab-versions."2024-2";

    "2025-1" =
      let
        args = rec {
          name = "xilinx-lab";
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
        install-config = final.xilinx-lab-utils.genInstallConfig args;

        unwrapped = final.xilinx-lab-utils.install args;
        xilinx-lab = final.xilinx-lab-utils.wrap {
          inputDerivation = final.xilinx-lab-versions."2025-1".unwrapped;
        };
      };

    "2024-2" =
      let
        args = rec {
          name = "xilinx-lab";
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
        install-config = final.xilinx-lab-utils.genInstallConfig args;

        unwrapped = final.xilinx-lab-utils.install args;
        xilinx-lab = final.xilinx-lab-utils.wrap {
          inputDerivation = final.xilinx-lab-versions."2024-2".unwrapped;
          extraTargetPkgs = pkgs: [ pkgs.libxcrypt-legacy ];
        };
      };
  };

  xilinx-lab-utils = {
    genInstallConfig = final.callPackage ./xilinx-pkgs/install.nix {
      genInstallConfig = true;
    };

    install = final.callPackage ./xilinx-pkgs/install.nix { };

    wrap = final.callPackage ./xilinx-pkgs/wrap.nix { };
  };
}
