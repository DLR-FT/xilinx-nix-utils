{
  description = "A collection of scripts for AMD/Xilinx Vitis/Vivado";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs?ref=nixos-24.11";
    devshell.url = "github:numtide/devshell";
    devshell.inputs.nixpkgs.follows = "nixpkgs";
    treefmt.url = "github:numtide/treefmt-nix";
    treefmt.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs =
    {
      self,
      nixpkgs,
      devshell,
      treefmt,
    }:
    let
      system = "x86_64-linux";
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
          devshell.overlays.default
        ];
      };

      treefmtEval = treefmt.lib.evalModule pkgs ./treefmt.nix;
    in
    {
      packages.${system} = {
        xilinx-unified = pkgs.xilinx-unified;
        xilinx-fhs = pkgs.genXilinxFhs { runScript = ""; };
      };

      devShells.${system}.default = pkgs.devshell.mkShell {
        name = "xilinx-dev-shell";

        imports = [ "${devshell}/extra/git/hooks.nix" ];

        packages = [
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

      overlays.default = import ./xilinx-unified.nix;
    };
}
