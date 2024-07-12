{
  description = "A collection of scripts for Xilinx Vitis/Vivado";

  inputs = {
    flake-utils.url = "github:numtide/flake-utils";
    devshell.url = "github:numtide/devshell";
    devshell.inputs.nixpkgs.follows = "nixpkgs";
    devshell.inputs.flake-utils.follows = "flake-utils";
    treefmt-nix.url = "github:numtide/treefmt-nix";
    treefmt-nix.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, nixpkgs, flake-utils, treefmt-nix, ... } @ inputs:
    flake-utils.lib.eachSystem [ "x86_64-linux" ]
      (system:
        let
          # checkout of the nixpkgs
          pkgs = import nixpkgs {
            inherit system;
            overlays = [
              # https://github.com/NixOS/nixpkgs/pull/42637
              (final: prev: {
                requireFile = args: (prev.requireFile args).overrideAttrs (_: { allowSubstitutes = true; });
              })

              self.overlays.default

              inputs.devshell.overlays.default
            ];
          };

          treefmtEval = treefmt-nix.lib.evalModule pkgs ./treefmt.nix;
        in
        rec {
          packages = {
            xilinx-unified-unwraped = pkgs.xilinx-unified-unwrapped;
            xilinx-unified = pkgs.xilinx-unified;
            xilinx-fhs = pkgs.genXilinxFhs { runScript = ""; };
          };

          devShells.default = pkgs.devshell.mkShell {
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
            commands =
              let
                commandTemplate = command: ''
                  set +u
                  exec ${./.}/commands/${command} "''${@}"
                '';
                commands = {
                  create-project = "creates a new project based on a template";
                  store = "create a restore script for a given project";
                  restore = "restore a project using a generated restore script";
                  build-hw-config = "generate a hw config for given platform";
                  build-bootloader = "build the bootloader for a script";
                  jtag-boot = "deploy a firmware via jtag";
                  launc-picocom = "launc the picocom serial monitor";
                };
              in
              [
                {
                  name = "show-readme";
                  command = ''glow "$PRJ_ROOT/README.md"'';
                  help = "";
                }
              ] ++ (pkgs.lib.mapAttrsToList
                (name: help: {
                  inherit name help;
                  command = commandTemplate name;
                })
                commands);
          };


          # for `nix fmt`
          formatter = treefmtEval.config.build.wrapper;
          # for `nix flake check`
          checks = {
            formatting = treefmtEval.config.build.check self;
            shellcheck = pkgs.runCommand "shellcheck" { nativeBuildInputs = [ pkgs.shellcheck ]; }
              "cd ${./.} && shellcheck commands/*; touch $out";
          };

          # just add every package as a hydra job
          hydraJobs = packages;
        }
      ) // {
      overlays.default = import ./overlay.nix;
    };
}
