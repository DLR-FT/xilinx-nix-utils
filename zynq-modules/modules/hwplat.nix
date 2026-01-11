{
  config,
  lib,
  pkgs,
  ...
}:
{
  options.hwplat = {
    name = lib.mkOption {
      type = with lib.types; singleLineStr;
      description = "name";
      default = config.name + "-hwplat";
    };

    version = lib.mkOption {
      type = with lib.types; nullOr singleLineStr;
      description = "version";
      default = null;
    };

    src = lib.mkOption {
      type = with lib.types; path;
      description = "Exported (write_project_tcl) Vivado project directory path.";
    };

    sourceTcl = lib.mkOption {
      type = with lib.types; path;
      description = "Source tcl file path.";
      default = lib.path.append config.hwplat.src "./vivado.tcl";
    };

    extraPatches = lib.mkOption {
      type = with lib.types; listOf path;
      description = "Extra patches to apply to the src directory.";
      default = [ ];
    };

    package = lib.mkOption {
      type = with lib.types; package;
      description = "Package containing the Hardware-Platform and Bitstream.";
    };
  };

  config = {
    fwPackages = [ config.hwplat.package ];

    hwplat = {
      package = lib.mkDefault (
        pkgs.zynq-pkgs.hwplat {
          name = config.hwplat.name;
          version = config.hwplat.version;
          src = config.hwplat.src;
          sourceTcl = config.hwplat.sourceTcl;
          extraPatches = config.hwplat.extraPatches;
        }
      );
    };
  };
}
