final: prev: {
  checkCommands = final.callPackage ./pkgs/check-commands.nix { };

  genXilinxFhs = final.callPackage ./pkgs/xilinx-fhs.nix { };


  xilinx-unified-unwrapped = final.xilinx-unified-2023-1-unwrapped;
  xilinx-unified = final.callPackage ./pkgs/wrap-xilinx.nix {
    inputDerivation = final.xilinx-unified-unwrapped;
  };

  xilinx-unified-2023-1-unwrapped = final.callPackage ./pkgs/xilinx-unified.nix { };
  xilinx-unified-2023-1 = final.callPackage ./pkgs/wrap-xilinx.nix { inputDerivation = final.xilinx-unified-2023-1-unwrapped; };

  xilinx-vivado-2019-2-unwrapped = (final.callPackage ./pkgs/xilinx-unified.nix {
    agreements = [ "XilinxEULA" "3rdPartyEULA" "WebTalkTerms" ];
  }).overrideAttrs (old: rec {
    pname = "xilinx-vivado";
    version = "2019.2_1106_2127";
    src = final.requireFile {
      name = "Xilinx_Vivado_${version}.tar.gz";
      url = "https://www.xilinx.com/";
      hash = "sha256-sGeBz7KUW6lI8Eo1nobWZmxkK+d2VidnxZ91FcqaDpY=";
    };
  });
  xilinx-vivado-2019-2 = final.callPackage ./pkgs/wrap-xilinx.nix {
    inputDerivation = final.xilinx-vivado-2019-2-unwrapped;
  };
}
