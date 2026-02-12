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
      type = with lib.types; strMatching "[a-zA-Z0-9_-]+";
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
                Specifies the order of the partition in relation to other partitions in the final boot BIF.
                Lower numbers appear before higher numbers.
                The default partitions use order 100, 200, 300, etc ,to enable extra partitions to be inserted before, between and after.
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
              description = ''
                Specifies the options of the partition. Suc as [bootloader, destination_cpu=\"a53-0\", ...].
                Boolean are formatted into an empty string or a single keyword, depending on the value.
                Options that are null are omitted.'';
              default = { };
            };

            file = lib.mkOption {
              type = with lib.types; path;
              description = "The file containing the data of the partition.";
            };
          };
        };
      in
      lib.mkOption {
        type = with lib.types; attrsOf (nullOr partition);
        description = ''
          Defines partitions in the boot image.
          Partitions that are null are omitted.'';
        default = { };
      };

    bootBif = lib.mkOption {
      type = with lib.types; str;
      description = ''
        Boot BIF used to generate the boot image.
        By default it is generated from the specified partitions.'';
    };

    dualQspiMode = lib.mkOption {
      type =
        with lib.types;
        nullOr (enum [
          "parallel"
          "stacked"
        ]);
      description = "Specifies that the boot image targets a dual (either 'parallel' or 'stacked') QSPI flash.";
      default = null;
    };

    extraArgs = lib.mkOption {
      type = with lib.types; listOf singleLineStr;
      description = "Extra args for bootgen tool invocation.";
      default = [ ];
    };

    package = lib.mkOption {
      type = with lib.types; package;
      description = "Package containing the generated boot image.";
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

    flash-qspi.bootImages = lib.mkDefault config.boot-image.package.bin;
  };
}
