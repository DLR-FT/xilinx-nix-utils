{
  config,
  lib,
  pkgs,
  ...
}:
{
  options.sdt = {
    enable = lib.mkEnableOption "Enable System-Device-Tree build.";

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
      description = "SDT source repo. (github:xilinx/system-device-tree-xlnx)";
      default = pkgs.zynq-srcs.sdt-src;
    };

    hwDef = lib.mkOption {
      type = with lib.types; path;
      description = "Hardware definition file (*.xsa).";
    };

    boardDts = lib.mkOption {
      type = with lib.types; nullOr singleLineStr;
      description = "Board specific .dtsi file, from the SDT repo (see github:Xilinx/system-device-tree-xlnx).";
      default = null;
    };

    extraDtsi = lib.mkOption {
      type = with lib.types; nullOr singleLineStr;
      description = "User defined custom .dtsi file (see github:Xilinx/system-device-tree-xlnx).";
      default = null;
    };

    extraPatches = lib.mkOption {
      type = with lib.types; listOf path;
      description = "Extra patches to apply to the src repo.";
      default = [ ];
    };

    package = lib.mkOption {
      type = with lib.types; package;
      description = "Package containing the System-Device-Tree";
    };
  };

  config = lib.mkIf config.sdt.enable {
    fwPackages = [ config.sdt.package ];

    sdt = {
      package = lib.mkDefault (
        pkgs.zynq-pkgs.sdt {
          name = config.sdt.name;
          version = config.sdt.version;
          src = config.sdt.src;

          xsa = config.sdt.hwDef;
          boardDts = config.sdt.boardDts;
          extraDtsi = config.sdt.extraDtsi;
          extraPatches = config.sdt.extraPatches;
        }
      );
    };

    pmufw.systemDeviceTree = lib.mkDefault config.sdt.package;
    fsbl.systemDeviceTree = lib.mkDefault config.sdt.package;
    linux-dt.systemDeviceTree = lib.mkDefault config.sdt.package;
  };
}
