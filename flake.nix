{
  description = "A collection of scripts for AMD/Xilinx Vitis/Vivado";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs?ref=nixos-24.11";
    devshell.url = "github:numtide/devshell";
    devshell.inputs.nixpkgs.follows = "nixpkgs";
    treefmt-nix.url = "github:numtide/treefmt-nix";
    treefmt-nix.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs =
    {
      self,
      nixpkgs,
      treefmt-nix,
      ...
    }@inputs:
    let
      system = "x86_64-linux";
      # checkout of the nixpkgs
      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfree = true;
        overlays = [
          # https://github.com/NixOS/nixpkgs/pull/42637
          (final: prev: {
            requireFile =
              args:
              (prev.requireFile args).overrideAttrs (_: {
                allowSubstitutes = true;
              });
          })

          self.overlays.default

          inputs.devshell.overlays.default
        ];
      };

      treefmtEval = treefmt-nix.lib.evalModule pkgs ./treefmt.nix;
    in
    {
      packages.${system} = {
        xilinx-unified-unwraped = pkgs.xilinx-unified-unwrapped;
        xilinx-unified = pkgs.xilinx-unified;

        # Add future version here

        xilinx-unified-2024-2-unwraped = pkgs.xilinx-unified-2024-2-unwrapped;
        xilinx-unified-2024-2 = pkgs.xilinx-unified-2024-2;

        xilinx-unified-2024-1-unwraped = pkgs.xilinx-unified-2024-1-unwrapped;
        xilinx-unified-2024-1 = pkgs.xilinx-unified-2024-1;

        xilinx-unified-2023-2-unwraped = pkgs.xilinx-unified-2023-2-unwrapped;
        xilinx-unified-2023-2 = pkgs.xilinx-unified-2023-2;

        xilinx-unified-2023-1-unwraped = pkgs.xilinx-unified-2023-1-unwrapped;
        xilinx-unified-2023-1 = pkgs.xilinx-unified-2023-1;

        xilinx-vivado-2019-2-unwraped = pkgs.xilinx-vivado-2019-2-unwrapped;
        xilinx-vivado-2019-2 = pkgs.xilinx-vivado-2019-2;

        xilinx-fhs = pkgs.genXilinxFhs { runScript = ""; };
      };

      devShells.${system}.default = pkgs.devshell.mkShell {
        imports = [ "${inputs.devshell}/extra/git/hooks.nix" ];
        name = "xilinx-dev-shell";
        packages = [
          pkgs.coreutils
          pkgs.glow
          pkgs.python3
          pkgs.unzip
          pkgs.xilinx-unified
        ];
        git.hooks = {
          enable = true;
          pre-commit.text = ''
            nix flake check
          '';
        };
      };

      # for `nix fmt`
      formatter.${system} = treefmtEval.config.build.wrapper;

      # for `nix flake check`
      checks.${system}.formatting = treefmtEval.config.build.check self;

      overlays.default = import ./overlay.nix;
    };
}
