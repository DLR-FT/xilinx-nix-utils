{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.11";
    nixpkgs-2505.url = "github:nixos/nixpkgs/nixos-25.05";

    xlnx-utils.url = "github:dlr-ft/xilinx-nix-utils/zynq-modules";
    xlnx-utils.inputs.nixpkgs.follows = "nixpkgs";

    treefmt.url = "github:numtide/treefmt-nix";
    treefmt.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs =
    {
      self,
      nixpkgs,
      nixpkgs-2505,
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
              pkgs = import nixpkgs-2505 {
                inherit system;
              };
            in
            {
              ratarmount = pkgs.ratarmount;
            }
          )

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
          xlnx-utils.overlays.zynq-patches
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
          # And add additional modules to add, or overwrite config options.
          modules = [
            ./kria-kr260-customization.nix
          ];
        };

        # Or configure a new firmware
        custom-board = pkgs.callPackage ./custum-board.nix;
      };

      devShells.${system} = {
        default = pkgs.mkShell {
          name = "default";
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
