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
      type = with lib.types; strMatching "[a-zA-Z0-9_-]+";
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
      description = "Specifies the source directory from which the hardware platform is build.";
    };

    sourceTcl = lib.mkOption {
      type = with lib.types; nullOr singleLineStr;
      description = ''
        Specifies a tcl file in the source directory that will be sourced to restore the exported Vivado project.
        Set to null to skip project restore from tcl.'';
      default = "./vivado.tcl";
    };

    originDir = lib.mkOption {
      type = with lib.types; nullOr singleLineStr;
      description = "Specifies the origin directory in the source directory, that contains the source files for the exported Vivado project.";
      default = "./.";
    };

    extraPatches = lib.mkOption {
      type = with lib.types; listOf path;
      description = "Specifies extra patches to apply to the source directory before the build.";
      default = [ ];
    };

    package = lib.mkOption {
      type = with lib.types; package;
      description = "Package containing the build Hardware-Platform and Bitstream.";
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
      order = 300;
      options = {
        destination_device = lib.mkIf (config.plat == "zynqmp") (lib.mkDefault "pl");
      };
      file = lib.mkDefault config.hwplat.package.bit;
    };
    boot-jtag.bit = lib.mkDefault config.hwplat.package.bit;
  };
}
