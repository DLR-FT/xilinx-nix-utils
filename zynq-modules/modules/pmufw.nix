{
  config,
  lib,
  pkgs,
  ...
}:
{
  options.pmufw = {
    enable = lib.mkEnableOption "Enable PMU firmware build.";

    name = lib.mkOption {
      type = with lib.types; singleLineStr;
      description = "name";
      default = config.name + "-pmufw";
    };

    version = lib.mkOption {
      type = with lib.types; nullOr singleLineStr;
      description = "version";
      default = null;
    };

    src = lib.mkOption {
      type = with lib.types; path;
      description = "PMU source repo (github: xilinx/embdeddedsw).";
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
      description = "stdenv used to build the pmufw.";
    };

    package = lib.mkOption {
      type = with lib.types; package;
      description = "Package containing the PMU firmware.";
    };
  };

  config = lib.mkIf config.pmufw.enable {
    fwPackages = [ config.pmufw.package ];

    pmufw = {
      procId = lib.mkDefault ({ zynqmp = "psu_pmu_0"; }.${config.plat});

      stdenv = lib.mkDefault (
        if lib.hasInfix "pmu" config.pmufw.procId then
          pkgs.pkgsCross.microblaze-embedded.stdenv
        else
          throw ""
      );

      package = lib.mkDefault (
        pkgs.zynq-pkgs.pmufw {
          name = config.pmufw.name;
          version = config.pmufw.version;
          src = config.pmufw.src;
          stdenv = config.pmufw.stdenv;

          sdt = config.pmufw.systemDeviceTree;
          plat = config.plat;
          proc = config.pmufw.procId;
          extraPatches = config.pmufw.extraPatches;
        }
      );
    };

    boot-image.partitions.pmufw = {
      order = lib.mkDefault 200;
      options = {
        pmufw_image = true;
      };
      file = lib.mkDefault config.pmufw.package.elf;
    };
    boot-jtag.pmufw = lib.mkDefault config.pmufw.package.elf;
  };
}
