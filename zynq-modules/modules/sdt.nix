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
      type = with lib.types; strMatching "[a-zA-Z0-9_-]+";
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
      description = "Specifies the SDT source repo. (e.g. github:xilinx/system-device-tree-xlnx)";
      default = pkgs.zynq-srcs.sdt-src;
    };

    hwDef = lib.mkOption {
      type = with lib.types; path;
      description = "Specifies the hardware definition file (*.xsa) from which the System-Device-Tree is generated.";
    };

    boardDts = lib.mkOption {
      type = with lib.types; nullOr singleLineStr;
      description = "Specifies extra, board specific device-tree include file, from the SDT repo (see github:Xilinx/system-device-tree-xlnx).";
      default = null;
    };

    extraDtsi = lib.mkOption {
      type = with lib.types; nullOr singleLineStr;
      description = "Specifies extra, user defined device-tree include file (see github:Xilinx/system-device-tree-xlnx).";
      default = null;
    };

    extraPatches = lib.mkOption {
      type = with lib.types; listOf path;
      description = "Specifies extra patches to apply to the source directory before the build.";
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
