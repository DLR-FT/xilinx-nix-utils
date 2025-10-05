{
  description = "A Nix wrapper for the Xilinx Unified Toolchain and additional utilities for using Nix as a build system for Zynq firmware";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.11";
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
          # (final: prev: {
          #   pkgsCross = prev.pkgsCross // {
          #     armhf-embedded = import nixpkgs {
          #       localSystem = system;
          #       crossSystem = {
          #         config = "arm-none-eabihf";
          #         gcc.arch = "armv7-a+fp";
          #         gcc.tune = "cortex-a9";
          #       };

          #       overlays = [
          #         self.overlays.zynq-srcs
          #         self.overlays.zynq-utils
          #       ];
          #     };
          #   };
          # })

          self.overlays.xilinx-lab
          self.overlays.xilinx-unified
          self.overlays.zynq-srcs
          self.overlays.zynq-utils
          self.overlays.zynq-boards

          (final: prev: {
            zynq-srcs = prev.zynq-srcs // {
              uboot-src = pkgs.fetchFromGitHub {
                owner = "Xilinx";
                repo = "u-boot-xlnx";
                rev = "xlnx_rebase_v2025.01";
                hash = "sha256-RTcd7MR37E4yVGWP3RMruyKBI4tz8ex7mY1f5F2xd00=";
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
          example = pkgs.zynq-boards.kria-kr260;
        in
        {
          xilinx-unified = pkgs.xilinx-unified;
          xilinx-lab = pkgs.xilinx-lab;

          bootgen = pkgs.zynq-utils.bootgen;

          hwplat = example.hwplat;
          sdt = example.sdt;
          pmufw = example.pmufw;
          fsbl = example.fsbl;
          tfa = example.tfa;
          linux-dt = example.linux-dt;
          uboot = example.uboot;
          fw = example.boot-image;
          boot = example.boot-jtag;
          flash = example.flash-qspi;
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

      # for `nix fmt`
      formatter.${system} = treefmtEval.config.build.wrapper;

      # for `nix flake check`
      checks.${system}.formatting = treefmtEval.config.build.check self;

      overlays.xilinx-lab = import ./xilinx-lab.nix;
      overlays.xilinx-unified = import ./xilinx-unified.nix;
      overlays.zynq-boards = import ./zynq-boards.nix;
      overlays.zynq-srcs = import ./zynq-srcs.nix;
      overlays.zynq-utils = import ./zynq-utils.nix;
    };
}
