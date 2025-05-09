final: prev: {
  zynq-boards = {
    te0706-0821-3be21 = prev.callPackage ./zynq-boards/te0706-0821-3be21/board.nix { };
    kria-kr260 = prev.callPackage ./zynq-boards/kria-kr260/board.nix { };
  };
}
