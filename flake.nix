{
  description = "A Nix wrapper for the Xilinx Unified Toolchain and additional utilities for using Nix as a build system for Zynq firmware";

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
                  self.overlays.zynq-srcs
                  self.overlays.zynq-utils
                ];
              };
            };
          })

          self.overlays.default
          self.overlays.zynq-srcs
          self.overlays.zynq-utils
          self.overlays.zynq-boards

          (final: prev: {
            zynq-srcs = prev.zynq-srcs // {
              uboot-src = pkgs.fetchFromGitHub {
                owner = "Xilinx";
                repo = "u-boot-xlnx";
                rev = "xlnx_rebase_v2025.01";
                hash = "sha256-uN6oXoa6huclsz1c5Z2IyIvJoRfMr1QsfKF6Y2Z4zf4=";
              };
            };
          })

          devshell.overlays.default
        ];
      };

      treefmtEval = treefmt.lib.evalModule pkgs ./treefmt.nix;
    in
    {
      packages.${system} =
        let
          example = pkgs.zynq-boards.te0706-0821-3be21;
        in
        {
          xilinx-unified = pkgs.xilinx-unified;
          xilinx-fhs = pkgs.genXilinxFhs { runScript = ""; };

          fw = example.boot-image;
          boot = example.boot-jtag;
          flash = example.flash-qspi;
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
            nix fmt
            nix flake check
          '';
        };
      };

      # for `nix fmt`
      formatter.${system} = treefmtEval.config.build.wrapper;

      # for `nix flake check`
      checks.${system}.formatting = treefmtEval.config.build.check self;

      overlays.default = import ./xilinx-unified.nix;
      overlays.zynq-srcs = import ./zynq-srcs.nix;
      overlays.zynq-utils = import ./zynq-utils.nix;
      overlays.zynq-boards = import ./zynq-boards.nix;
    };
}
