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
      type = with lib.types; singleLineStr;
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
      description = "FSBL source repo (github: xilinx/embeddedsw).";
      default = pkgs.zynq-srcs.embeddedsw-src;
    };

    systemDeviceTree = lib.mkOption {
      type = with lib.types; path;
      description = "System-Device-Tree sources.";
    };

    procId = lib.mkOption {
      type = with lib.types; singleLineStr;
      description = "Zynq processor id (ps7_cortexa9_0, psu_cortexa53_0, psu_pmu_0, ...).";
    };

    extraPatches = lib.mkOption {
      type = with lib.types; listOf path;
      description = "Extra patches to apply to the src repo.";
      default = [ ];
    };

    stdenv = lib.mkOption {
      type = with lib.types; package;
      description = "stdenv used to build the fsbl.";
    };

    package = lib.mkOption {
      type = with lib.types; package;
      description = "Package containing the FSBL firmware";
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
          throw ""
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
