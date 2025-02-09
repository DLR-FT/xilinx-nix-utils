final: prev: {
  checkCommands = final.callPackage ./pkgs/check-commands.nix { };

  genXilinxFhs = final.callPackage ./pkgs/xilinx-fhs.nix { };

  xilinx-unified-unwrapped = final.xilinx-unified-2023-1-unwrapped;
  xilinx-unified = final.callPackage ./pkgs/wrap-xilinx.nix {
    inputDerivation = final.xilinx-unified-unwrapped;
  };

  xilinx-unified-2023-1-unwrapped = final.callPackage ./pkgs/xilinx-unified.nix {
    filename = v: "Xilinx_Unified_${v}.tar.gz";
    version = "2023.1_0507_1903";
    hash = "sha256-Kq7GwlDvdTP+X3+u1bjQUkcy7+7FNFnbOiIJXF87nDk=";
  };
  xilinx-unified-2023-1 = final.callPackage ./pkgs/wrap-xilinx.nix {
    inputDerivation = final.xilinx-unified-2023-1-unwrapped;
  };

  xilinx-unified-2023-2-unwrapped = final.callPackage ./pkgs/xilinx-unified.nix {
    filename = v: "FPGAs_AdaptiveSoCs_Unified_${v}.tar.gz";
    version = "2023.2_1013_2256";
    hash = "sha256-SCRztYAKux101RudvueXp19EPUBfxGqQMfMMIBa2r6o=";
  };
  xilinx-unified-2023-2 = final.callPackage ./pkgs/wrap-xilinx.nix {
    inputDerivation = final.xilinx-unified-2023-2-unwrapped;
  };

  xilinx-vivado-2019-2-unwrapped =
    (final.callPackage ./pkgs/xilinx-unified.nix {
      agreements = [
        "XilinxEULA"
        "3rdPartyEULA"
        "WebTalkTerms"
      ];
    }).overrideAttrs
      (old: rec {
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
