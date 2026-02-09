{
  config,
  lib,
  pkgs,
  ...
}:
{
  options.boot-image = {
    enable = lib.mkEnableOption "Enable Boot-Image build.";

    name = lib.mkOption {
      type = with lib.types; singleLineStr;
      description = "name";
      default = config.name + "-boot-image";
    };

    version = lib.mkOption {
      type = with lib.types; nullOr singleLineStr;
      description = "version";
      default = null;
    };

    partitions =
      let
        partition = lib.types.submodule {
          options = {
            order = lib.mkOption {
              type = with lib.types; int;
              description = ''
                Order of the partition. Determines the position in the boot BIF file, in relation to other partitions.
                Lower orders appear before higher orders.
              '';
              default = 1000;
            };

            options = lib.mkOption {
              type =
                with lib.types;
                nullOr (
                  attrsOf (
                    nullOr (oneOf [
                      bool
                      int
                      singleLineStr
                    ])
                  )
                );
              description = "";
              default = { };
            };

            file = lib.mkOption {
              type = with lib.types; path;
              description = "";
            };
          };
        };
      in
      lib.mkOption {
        type = with lib.types; attrsOf (nullOr partition);
        description = "Defines partitions in the boot image.";
        default = { };
      };

    bootBif = lib.mkOption {
      type = with lib.types; str;
      description = "Boot BIF used to generate the boot image.";
    };

    dualQspiMode = lib.mkOption {
      type = with lib.types; nullOr singleLineStr;
      description = "Generate boot-image for dual-qspi flash. Either \"parallel\" or \"stacked <size>\". See Xilinx bootgen.";
      default = null;
    };

    extraArgs = lib.mkOption {
      type = with lib.types; listOf singleLineStr;
      description = "Extra args for bootgen.";
      default = [ ];
    };

    package = lib.mkOption {
      type = with lib.types; package;
      description = "Package containing the Hardware-Platform and Bitstream.";
    };
  };

  config = lib.mkIf config.boot-image.enable {
    fwPackages = [ config.boot-image.package ];

    boot-image = {
      bootBif = lib.mkDefault (
        let
          toSnake = lib.strings.stringAsChars (ch: if ch == "-" then "_" else ch);

          formatOpt =
            k: v:
            {
              "bool" = if v then k else null;
              "int" = "${k} = ${builtins.toString v}";
              "string" = "${k} = ${v}";
              "null" = null;
            }
            .${builtins.typeOf v};

          formatOpts =
            opts:
            if opts == null || opts == { } then
              ""
            else
              lib.pipe opts [
                (lib.mapAttrsToList (k: v: formatOpt k v))
                (lib.filter (opt: opt != null))
                (x: "[${lib.concatStringsSep ", " x}] ")
              ];

          formatPart = part: "${formatOpts part.options}${part.file}";

          formatParts =
            parts:
            lib.pipe parts [
              (lib.filterAttrs (n: part: part != null))
              (lib.mapAttrsToList (n: part: part))
              (lib.sort (a: b: a.order < b.order))
              (lib.map formatPart)
            ];
        in
        ''
          ${toSnake config.name}:
          {
            ${lib.concatStringsSep "\n  " (formatParts config.boot-image.partitions)}
          }
        ''
      );

      package = lib.mkDefault (
        pkgs.zynq-pkgs.boot-image {
          name = config.boot-image.name;
          version = config.boot-image.version;

          arch =
            {
              zynq7 = "zynq";
              zynqmp = "zynqmp";
            }
            .${config.plat};

          bootBif = config.boot-image.bootBif;
          dualQspiMode = config.boot-image.dualQspiMode;
          extraArgs = config.boot-image.extraArgs;
        }
      );
    };

    flash-qspi.bootImage = lib.mkDefault config.boot-image.package.bin;
  };
}
