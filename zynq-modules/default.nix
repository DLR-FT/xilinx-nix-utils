{
  lib,
  pkgs,
  linkFarmFromDrvs,
}:
let
  defaultPkgs = pkgs;

  evalFwConfig =
    {
      modules,
      pkgs,
      extraModuleArgs,
    }:
    let
      baseModule =
        { ... }:
        {
          _module.args = {
            inherit pkgs;
          }
          // extraModuleArgs;
        };
    in
    lib.evalModules {
      modules = [
        baseModule
        (import ./modules)
      ]
      ++ modules;
    };

  buildFw =
    eval:
    let
      assertsDrv = with eval.config; lib.asserts.checkAssertWarn assertions warnings;

      configDrv =
        let
          # filterEnabled = lib.attrsets.filterAttrsRecursive (n: v: (v ? enable) -> v.enable);
          tryEvalConfig = lib.filterAttrsRecursive (n: v: (builtins.tryEval v).success);
        in
        with eval;
        pkgs.runCommand "${config.name}-config.json" { nativeBuildInputs = [ pkgs.jq ]; } ''
          echo ${lib.escapeShellArg (builtins.toJSON (tryEvalConfig config))} | jq >> $out
        '';

      fw = with eval.config; assertsDrv (linkFarmFromDrvs name (fwPackages ++ [ configDrv ]));

      passthruPkgs = lib.mapAttrs (name: subAttrs: subAttrs.package) (
        lib.filterAttrs (name: subAttrs: subAttrs ? package) eval.config
      );
    in
    fw.overrideAttrs {
      passthru = passthruPkgs // {
        inherit eval;

        extendFirmware =
          {
            modules ? [ ],
          }:
          buildFw (eval.extendModules { inherit modules; });
      };
    };
in
{
  mkZynqFirmware = lib.makeOverridable (
    {
      modules,
      pkgs ? defaultPkgs,
      extraModuleArgs ? { },
    }:
    buildFw (evalFwConfig {
      inherit modules pkgs extraModuleArgs;
    })
  );
}
