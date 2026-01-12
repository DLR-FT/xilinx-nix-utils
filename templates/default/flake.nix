{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.05";

    xlnx-utils.url = "github:dlr-ft/xilinx-nix-utils/zynq-modules";
    xlnx-utils.inputs.nixpkgs.follows = "nixpkgs";

    treefmt.url = "github:numtide/treefmt-nix";
    treefmt.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs =
    {
      self,
      nixpkgs,
      xlnx-utils,
      treefmt,
    }:
    let
      system = "x86_64-linux";

      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfree = true;

        overlays = [
          # For ARMv7A Cortex-A9 support; otherwise FSBL build will fail
          (final: prev: {
            pkgsCross = prev.pkgsCross // {
              armhf-embedded = import nixpkgs {
                localSystem = system;
                crossSystem = {
                  config = "arm-none-eabihf";
                  gcc.arch = "armv7-a+fp";
                  gcc.tune = "cortex-a9";
                };

                overlays = [
                  xlnx-utils.overlays.zynq-srcs
                  xlnx-utils.overlays.zynq-pkgs
                ];
              };
            };
          })

          # import xlnx-utils overlays
          xlnx-utils.overlays.xilinx-unified
          xlnx-utils.overlays.xilinx-lab
          xlnx-utils.overlays.zynq-srcs
          xlnx-utils.overlays.zynq-pkgs
          xlnx-utils.overlays.zynq-modules
          xlnx-utils.overlays.zynq-boards

        ];
      };

      treefmtEval = treefmt.lib.evalModule pkgs ./treefmt.nix;
    in
    {
      packages.${system} = {
        # Use an existing firmware as a starting point
        kria-kr260 = pkgs.zynq-boards.kria-kr260.extendFirmware {
          # Add additional modules to add or overwrite config options.
          modules = [
            ./kria-kr260.nix

            ({ config, lib, ... }: { })
          ];
        };

        # Or configure a new firmware
        my-custom-board = pkgs.callPackage ./my-custum-board.nix;
      };

      devShells.${system} = {
        default = pkgs.mkShell {
          name = "xilinx-nix-utils";
          packages = [ ];
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

      # for `nix fmt`
      formatter.${system} = treefmtEval.config.build.wrapper;

      # for `nix flake check`
      checks.${system}.formatting = treefmtEval.config.build.check self;
    };
}
