{
  description = "A Nix wrapper for the Xilinx Unified Toolchain and additional utilities for using Nix as a build system for Zynq firmware";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.11";

    # Just as a workaround
    nixpkgs2505.url = "github:nixos/nixpkgs/nixos-25.05";

    devshell.url = "github:numtide/devshell";
    devshell.inputs.nixpkgs.follows = "nixpkgs";
    treefmt.url = "github:numtide/treefmt-nix";
    treefmt.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs =
    {
      self,
      nixpkgs,
      nixpkgs2505,
      devshell,
      treefmt,
    }:
    let
      system = "x86_64-linux";

      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfree = true;

        overlays = [
          # https://github.com/NixOS/nixpkgs/pull/459393
          (
            final: prev:
            let
              pkgs = import nixpkgs2505 { inherit system; };
            in
            {
              ratarmount = pkgs.ratarmount;
            }
          )

          # https://github.com/NixOS/nixpkgs/pull/42637
          (final: prev: {
            requireFile =
              args:
              (prev.requireFile args).overrideAttrs (_: {
                allowSubstitutes = true;
              });
          })

          # Otherwise FSBL does not compile for Zynq7 Cortex-A9
          (final: prev: {
            pkgsCross = prev.pkgsCross // {
              armhf-embedded = import nixpkgs {
                localSystem = system;
                crossSystem = {
                  config = "arm-none-eabihf";
                  gcc.arch = "armv7-a+fp";
                  gcc.tune = "cortex-a9";
                };

                overlays = prev.overlays;
              };
            };
          })

          self.overlays.default
          self.overlays.xilinx-lab

          devshell.overlays.default
        ];
      };

      treefmtEval = treefmt.lib.evalModule pkgs ./treefmt.nix;
    in
    {
      packages.${system} = rec {
        xilinx-unified = pkgs.xilinx-unified;
        xilinx-lab = pkgs.xilinx-lab;

        bootgen = pkgs.zynq-pkgs.bootgen;

        kria-kr260 = pkgs.zynq-boards.kria-kr260;
        trenz-arduzynq = pkgs.zynq-boards.trenz-arduzynq;
        trenz-te0706 = pkgs.zynq-boards.trenz-te0706;

        zynq-options-md =
          let
            optionsMd = pkgs.nixosOptionsDoc {
              inherit (kria-kr260.eval) options;
            };
          in
          optionsMd.optionsCommonMark;
      };

      devShells.${system} = {
        default = pkgs.devshell.mkShell {
          name = "xilinx-nix-utils";
          imports = [ "${devshell}/extra/git/hooks.nix" ];

          packages = [ ];

          git.hooks = {
            enable = true;
            pre-commit.text = ''
              nix fmt
              nix flake check

              zynq_opts=$(mktemp -d)
              nix build .#zynq-options-md -o $zynq_opts/zynq-options.md
              cp -f $zynq_opts/zynq-options.md ./docs/zynq-options.md
              git add ./docs/zynq-options.md
            '';
          };
        };

        xilinx-lab = pkgs.devshell.mkShell {
          name = "xilinx-lab";
          packages = [ pkgs.xilinx-lab ];
        };

        xilinx-unified = pkgs.devshell.mkShell {
          name = "xilinx-unified";
          packages = [ pkgs.xilinx-unified ];
        };
      };

      templates = {
        default = {
          path = ./templates/default;
          description = "Default template";
        };
      };

      # for `nix fmt`
      formatter.${system} = treefmtEval.config.build.wrapper;

      # for `nix flake check`
      checks.${system}.formatting = treefmtEval.config.build.check self;

      # Merge common overlays into a single overlay
      overlays.default =
        final: prev:
        prev.lib.foldl (prev: overlay: prev // (overlay final prev)) prev [
          self.overlays.xilinx-unified
          self.overlays.zynq-srcs
          self.overlays.zynq-patches
          self.overlays.zynq-pkgs
          self.overlays.zynq-modules
          self.overlays.zynq-boards
        ];

      overlays.xilinx-lab = import ./xilinx-lab.nix;
      overlays.xilinx-unified = import ./xilinx-unified.nix;
      overlays.zynq-srcs = import ./zynq-srcs.nix;
      overlays.zynq-patches = import ./zynq-patches.nix;
      overlays.zynq-pkgs = import ./zynq-pkgs.nix;
      overlays.zynq-modules = import ./zynq-modules.nix;
      overlays.zynq-boards = import ./zynq-boards.nix;
    };
}
