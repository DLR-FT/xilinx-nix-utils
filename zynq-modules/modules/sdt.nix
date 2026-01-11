{
  config,
  lib,
  pkgs,
  ...
}:
{
  options.sdt = {
    name = lib.mkOption {
      type = with lib.types; singleLineStr;
      description = "name";
      default = config.name + "-sdt";
    };

    version = lib.mkOption {
      type = with lib.types; nullOr singleLineStr;
      description = "version";
      default = null;
    };

    src = lib.mkOption {
      type = with lib.types; path;
      description = "SDT source repo. (github: xilinx/system-device-tree-xlnx)";
      default = pkgs.zynq-srcs.sdt-src;
    };

    boardDts = lib.mkOption {
      type = with lib.types; nullOr singleLineStr;
      description = "";
      default = null;
    };

    extraDtsi = lib.mkOption {
      type = with lib.types; nullOr singleLineStr;
      description = "";
      default = null;
    };

    extraPatches = lib.mkOption {
      type = with lib.types; listOf path;
      description = "Extra patches to apply to the src repo.";
      default = [ ];
    };

    package = lib.mkOption {
      type = with lib.types; nullOr package;
      description = "Package containing the System-Device-Tree";
      default = null;
    };
  };

  config = {
    fwPackages = [ config.sdt.package ];

    sdt = {
      package = lib.mkDefault (
        pkgs.zynq-pkgs.sdt {
          name = config.sdt.name;
          version = config.sdt.version;
          src = config.sdt.src;

          hwplat = config.hwplat.package;
          boardDts = config.sdt.boardDts;
          extraDtsi = config.sdt.extraDtsi;
          extraPatches = config.sdt.extraPatches;
        }
      );
    };
  };
}
