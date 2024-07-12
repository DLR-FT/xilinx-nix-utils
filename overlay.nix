final: prev: {
  genXilinxFhs = final.callPackage ./pkgs/xilinx-fhs.nix { };

  xilinx-unified-unwrapped = final.callPackage ./pkgs/xilinx-unified.nix { };
  xilinx-unified = final.callPackage ./pkgs/wrap-xilinx.nix { inputDerivation = final.xilinx-unified-unwrapped; };
}
