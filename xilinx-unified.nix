final: prev: {
  xilinx-unified = final.xilinx-unified-versions.latest.xilinx-unified;

  # Provides xilinx-unified, or xilinx-lab, depending on which overlays are loaded.
  # Prioritizes always xilinx-unified, independently of the overlay order.
  xilinx-unified-or-lab = final.xilinx-unified;

  xilinx-unified-versions = {
    latest = final.xilinx-unified-versions."2024-2";

    "2025-1" =
      let
        args = rec {
          name = "xilinx-unified";
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
        # generates the default install_config.txt from the installer.
        install-config = final.xilinx-unified-utils.genInstallConfig args;

        unwrapped = final.xilinx-unified-utils.install args;
        xilinx-unified = final.xilinx-unified-utils.wrap {
          inputDerivation = final.xilinx-unified-versions."2025-1".unwrapped;
        };
      };

    "2024-2" =
      let
        args = rec {
          name = "xilinx-unified";
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
        install-config = final.xilinx-unified-utils.genInstallConfig args;

        unwrapped = final.xilinx-unified-utils.install args;
        xilinx-unified = final.xilinx-unified-utils.wrap {
          inputDerivation = final.xilinx-unified-versions."2024-2".unwrapped;
          extraTargetPkgs = pkgs: [ pkgs.libxcrypt-legacy ];
        };
      };

    "2024-1" =
      let
        args = rec {
          name = "xilinx-unified";
          version = "2024.1_0522_2023";
          installTar = final.requireFile {
            name = "FPGAs_AdaptiveSoCs_Unified_${version}.tar.gz";
            url = "https://www.xilinx.com/";
            hash = "sha256-AH7MJNhTMnaCCENluF26orxVCiZU/RF9bNbaHAnH8QM=";
          };
          installConfig = ./xilinx-pkgs/install-configs/xlnx-unified-2024-1.txt;
        };
      in
      {
        install-config = final.xilinx-unified-utils.genInstallConfig args;

        unwrapped = final.xilinx-unified-utils.install args;
        xilinx-unified = final.xilinx-unified-utils.wrap {
          inputDerivation = final.xilinx-unified-versions."2024-1".unwrapped;
          extraTargetPkgs = pkgs: [ pkgs.libxcrypt-legacy ];
        };
      };
  };

  xilinx-unified-utils = {
    genInstallConfig = final.callPackage ./xilinx-pkgs/install.nix {
      genInstallConfig = true;
    };

    install = final.callPackage ./xilinx-pkgs/install.nix { };
    wrap = final.callPackage ./xilinx-pkgs/wrap.nix { };
  };
}
