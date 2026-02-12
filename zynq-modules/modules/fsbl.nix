{
  config,
  lib,
  pkgs,
  ...
}:
{
  options.fsbl = {
    enable = lib.mkEnableOption "Enable BL2 FSBL build.";

    name = lib.mkOption {
      type = with lib.types; strMatching "[a-zA-Z0-9_-]+";
      description = "name";
      default = config.name + "-fsbl";
    };

    version = lib.mkOption {
      type = with lib.types; nullOr singleLineStr;
      description = "version";
      default = null;
    };

    src = lib.mkOption {
      type = with lib.types; path;
      description = "Specifies the FSBL source repo (e.g. github:xilinx/embeddedsw).";
      default = pkgs.zynq-srcs.embeddedsw-src;
    };

    systemDeviceTree = lib.mkOption {
      type = with lib.types; path;
      description = "Specifies the System-Device-Tree which is used to generate the BSP for the FSBL.";
    };

    procId = lib.mkOption {
      type =
        with lib.types;
        enum [
          "ps7_cortexa9_0"
          "psu_cortexa53_0"
        ];
      description = "Specifies the Zynq processor (ps7_cortexa9_0, psu_cortexa53_0, ...) for which the FSBL is build.";
    };

    extraPatches = lib.mkOption {
      type = with lib.types; listOf path;
      description = "Specifies extra patches to apply to the source directory before the build.";
      default = [ ];
    };

    stdenv = lib.mkOption {
      type = with lib.types; package;
      description = "Specifies the stdenv toolchain used to build the fsbl.";
    };

    package = lib.mkOption {
      type = with lib.types; package;
      description = "Package containing the build FSBL firmware";
    };
  };

  config = lib.mkIf config.fsbl.enable {
    fwPackages = [ config.fsbl.package ];

    fsbl = {
      procId = lib.mkDefault (
        {
          zynq7 = "ps7_cortexa9_0";
          zynqmp = "psu_cortexa53_0";
        }
        .${config.plat}
      );

      stdenv = lib.mkDefault (
        if lib.hasInfix "cortexa9" config.fsbl.procId then
          pkgs.pkgsCross.armhf-embedded.stdenv
        else if lib.hasInfix "cortexa53" config.fsbl.procId then
          pkgs.pkgsCross.aarch64-embedded.stdenv
        else
          throw "Unknown FSBL processor id."
      );

      package = lib.mkDefault (
        pkgs.zynq-pkgs.fsbl {
          name = config.fsbl.name;
          version = config.fsbl.version;
          src = config.fsbl.src;
          stdenv = config.fsbl.stdenv;

          sdt = config.fsbl.systemDeviceTree;
          plat = config.plat;
          proc = config.fsbl.procId;
          extraPatches = config.fsbl.extraPatches;
        }
      );
    };

    boot-image.partitions.bootloader = lib.mkDefault {
      order = lib.mkDefault 100;
      options = {
        bootloader = lib.mkDefault true;
        exception_level = lib.mkIf (config.plat == "zynqmp") (lib.mkDefault "el-3");
      };
      file = config.fsbl.package.elf;
    };
    boot-jtag.fsbl = lib.mkDefault config.fsbl.package.elf;
    flash-qspi.initFsbl = lib.mkDefault config.fsbl.package.elf;
  };
}
