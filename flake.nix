{
  description = "A Nix wrapper for the Xilinx Unified Toolchain and additional utilities for using Nix as a build system for Zynq firmware";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.11";

    # TODO: remove
    nixpkgs-2505.url = "github:nixos/nixpkgs/nixos-25.05";

    devshell.url = "github:numtide/devshell";
    devshell.inputs.nixpkgs.follows = "nixpkgs";
    treefmt.url = "github:numtide/treefmt-nix";
    treefmt.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs =
    {
      self,
      nixpkgs,
      nixpkgs-2505,
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
              pkgs = import nixpkgs-2505 {
                inherit system;
              };
            in
            {
              ratarmount = pkgs.ratarmount;
            }
          )

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

          self.overlays.xilinx-lab
          self.overlays.xilinx-unified
          self.overlays.zynq-srcs
          self.overlays.zynq-patches
          self.overlays.zynq-pkgs
          self.overlays.zynq-modules
          self.overlays.zynq-boards

          devshell.overlays.default
        ];
      };

      treefmtEval = treefmt.lib.evalModule pkgs ./treefmt.nix;
    in
    {
      packages.${system} = {
        xilinx-unified = pkgs.xilinx-unified;
        xilinx-lab = pkgs.xilinx-lab;

        bootgen = pkgs.zynq-pkgs.bootgen;

        kria-kr260 = pkgs.zynq-boards.kria-kr260;
        trenz-small = pkgs.zynq-boards.te0706-0821-3be21;
      };

      devShells.${system} = {
        default = pkgs.devshell.mkShell {
          name = "xilinx-nix-utils";
          imports = [ "${devshell}/extra/git/hooks.nix" ];

          packages = [ pkgs.nix-tree ];

          git.hooks = {
            enable = true;
            pre-commit.text = ''
              nix fmt
              nix flake check
            '';
          };
        };

        xilinx-lab = pkgs.devshell.mkShell {
          name = "xilinx-lab";
          packages = [ pkgs.xilinx-lab ];
        };

        xilinx-unified = pkgs.devshell.mkShell {
          name = "xilinx-unified";
          packages = [
            pkgs.xilinx-unified
          ];
        };
      };

      templates = {
        default = {
          path = ./templates/default;
          description = "Default template for reusing or configuring a firmware.";
        };
      };

      # for `nix fmt`
      formatter.${system} = treefmtEval.config.build.wrapper;

      # for `nix flake check`
      checks.${system}.formatting = treefmtEval.config.build.check self;

      overlays.xilinx-lab = import ./xilinx-lab.nix;
      overlays.xilinx-unified = import ./xilinx-unified.nix;
      overlays.zynq-srcs = import ./zynq-srcs.nix;
      overlays.zynq-patches = import ./zynq-patches.nix;
      overlays.zynq-pkgs = import ./zynq-pkgs.nix;
      overlays.zynq-modules = import ./zynq-modules.nix;
      overlays.zynq-boards = import ./zynq-boards.nix;
    };
}
