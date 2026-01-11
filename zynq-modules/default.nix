{
  lib,
  pkgs,
  runCommand,
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
      modules = [ baseModule ] ++ modules;
    };

  buildFw =
    eval:
    runCommand ""
      {
        passthru = {
          inherit eval;
          extendFirmware =
            {
              modules ? [ ],
            }:
            buildFw (eval.extendModules { inherit modules; });
        };
      }
      ''
        mkdir $out
        echo ${lib.escapeShellArg (builtins.toJSON eval.config)} >> $out/config.json
      '';
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
