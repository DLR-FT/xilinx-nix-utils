{
  config,
  lib,
  pkgs,
  ...
}:
{
  options.hwplat = {
    enable = lib.mkEnableOption "Enable hardware platform build.";

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
      description = "Hardware platform source directory.";
    };

    sourceTcl = lib.mkOption {
      type = with lib.types; nullOr singleLineStr;
      description = "Source tcl file path. Set to ${null} to skip project sourcing from tcl.";
      default = "./vivado.tcl";
    };

    originDir = lib.mkOption {
      type = with lib.types; nullOr singleLineStr;
      description = "Origin directory, that contains the project source files.";
      default = "./.";
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

  config = lib.mkIf config.hwplat.enable {
    fwPackages = [ config.hwplat.package ];

    hwplat = {
      package = lib.mkDefault (
        pkgs.zynq-pkgs.hwplat {
          name = config.hwplat.name;
          version = config.hwplat.version;
          src = config.hwplat.src;

          sourceTcl = config.hwplat.sourceTcl;
          originDir = config.hwplat.originDir;
          extraPatches = config.hwplat.extraPatches;
        }
      );
    };

    sdt.hwDef = lib.mkDefault config.hwplat.package.xsa;
    boot-image.partitions.pl = {
      order = lib.mkDefault 300;
      options = {
        destination_device = lib.mkIf (config.plat == "zynqmp") "pl";
      };
      file = lib.mkDefault config.hwplat.package.bit;
    };
    boot-jtag.bit = lib.mkDefault config.hwplat.package.bit;
  };
}
