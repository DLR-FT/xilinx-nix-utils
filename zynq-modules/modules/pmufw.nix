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
      type = with lib.types; strMatching "[a-zA-Z0-9_-]+";
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
      description = "Specifies the PMU source repo (e.g. github:xilinx/embdeddedsw).";
      default = pkgs.zynq-srcs.embeddedsw-src;
    };

    systemDeviceTree = lib.mkOption {
      type = with lib.types; path;
      description = "System-Device-Tree sources.";
    };

    procId = lib.mkOption {
      type = with lib.types; enum [ "psu_pmu_0" ];
      description = "Specifies the Zynq processor (psu_pmu_0, ...) for which the PMU firmware is build.";
    };

    extraPatches = lib.mkOption {
      type = with lib.types; listOf path;
      description = "Specifies extra patches to apply to the source directory before the build.";
      default = [ ];
    };

    stdenv = lib.mkOption {
      type = with lib.types; package;
      description = "Specifies the stdenv toolchain used to build the PMU firmware.";
    };

    package = lib.mkOption {
      type = with lib.types; package;
      description = "Package containing the build PMU firmware.";
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
          throw "Unknown PMU processor id."
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
      order = 200;
      options = {
        pmufw_image = lib.mkDefault true;
      };
      file = lib.mkDefault config.pmufw.package.elf;
    };
    boot-jtag.pmufw = lib.mkDefault config.pmufw.package.elf;
  };
}
