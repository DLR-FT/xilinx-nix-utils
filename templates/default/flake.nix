{
  description = "A Nix wrapper for the Xilinx Unified Toolchain and additional utilities for using Nix as a build system for Zynq firmware";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.11";

    # Just as a workaround
    nixpkgs2505.url = "github:nixos/nixpkgs/nixos-25.05";

    xlnx-utils.url = "github:dlr-ft/xilinx-nix-utils";
    xlnx-utils.inputs.nixpkgs.follows = "nixpkgs";

    treefmt.url = "github:numtide/treefmt-nix";
    treefmt.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs =
    {
      self,
      nixpkgs,
      nixpkgs2505,
      xlnx-utils,
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

          # Add xilinx-nix-utils overlay
          xlnx-utils.overlays.default
        ];
      };

      treefmtEval = treefmt.lib.evalModule pkgs ./treefmt.nix;
    in
    {
      packages.${system} = {
        kria-kr260 = pkgs.zynq-boards.kria-kr260.extendFirmware {
          modules = [ ./kria-kr260-extra.nix ];
        };

        custom-board = pkgs.zynq-modules.mkZynqFirmware {
          modules = [ ./custom-board.nix ];
        };
      };

      devShells.${system}.default = pkgs.mkShell {
        packages = [ pkgs.xilinx-unified ];
      };

      # for `nix fmt`
      formatter.${system} = treefmtEval.config.build.wrapper;

      # for `nix flake check`
      checks.${system}.formatting = treefmtEval.config.build.check self;
    };
}
