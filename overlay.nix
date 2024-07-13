final: prev: {
  checkCommands = final.callPackage ./pkgs/check-commands.nix { };

  genXilinxFhs = final.callPackage ./pkgs/xilinx-fhs.nix { };

  xilinx-unified-unwrapped = final.callPackage ./pkgs/xilinx-unified.nix { };
  xilinx-unified = final.callPackage ./pkgs/wrap-xilinx.nix { inputDerivation = final.xilinx-unified-unwrapped; };
}
