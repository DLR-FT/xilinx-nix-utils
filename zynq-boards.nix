final: prev: {
  zynq-boards = {
    kria-kr260 = prev.callPackage ./zynq-boards/kria-kr260/board.nix { };
    trenz-arduzynq = prev.callPackage ./zynq-boards/trenz-arduzynq/board.nix { };
    trenz-te0706 = prev.callPackage ./zynq-boards/trenz-te0706/board.nix { };
  };
}
