{ config, lib, ... }:
{
  imports = [
    ./hwplat.nix
    ./sdt.nix
    ./pmufw.nix
    ./fsbl.nix
    ./tfa.nix
    ./optee-os.nix
    ./linux-dt.nix
    ./uboot.nix
    ./boot-image.nix
    ./boot-jtag.nix
    ./flash-qspi.nix
  ];

  options = {
    name = lib.mkOption {
      type = with lib.types; strMatching "[a-zA-Z0-9_-]+";
      description = "Name of the firmware.";
    };

    description = lib.mkOption {
      type = with lib.types; nullOr str;
      description = "Description of the firmware";
      default = null;
    };

    plat = lib.mkOption {
      type =
        with lib.types;
        enum [
          "zynq7"
          "zynqmp"
        ];
      description = "Zynq Platform variant, either Zynq 7000 or ZynqMP Ultrascale.";
    };

    fwPackages = lib.mkOption {
      type = with lib.types; listOf package;
      default = [ ];
      description = "Set of all firmware packages";
    };

    assertions = lib.mkOption {
      type = lib.types.listOf lib.types.unspecified;
      internal = true;
      default = [ ];
      example = [
        {
          assertion = false;
          message = "you can't enable this for that reason";
        }
      ];
      description = ''
        This option allows modules to express conditions that must
        hold for the evaluation of the system configuration to
        succeed, along with associated error messages for the user.
      '';
    };

    warnings = lib.mkOption {
      internal = true;
      default = [ ];
      type = lib.types.listOf lib.types.str;
      example = [ "The `foo' service is deprecated and will go away soon!" ];
      description = ''
        This option allows modules to show warnings to users during
        the evaluation of the system configuration.
      '';
    };
  };

  config = {
    hwplat.enable = lib.mkDefault true;
    sdt.enable = lib.mkDefault true;
    pmufw.enable = lib.mkDefault (config.plat == "zynqmp");
    fsbl.enable = lib.mkDefault true;
    tfa.enable = lib.mkDefault (config.plat == "zynqmp");
    optee-os.enable = lib.mkDefault false;
    linux-dt.enable = lib.mkDefault true;
    uboot.enable = lib.mkDefault true;
    boot-image.enable = lib.mkDefault true;
    boot-jtag.enable = lib.mkDefault true;
    flash-qspi.enable = lib.mkDefault true;

    boot-jtag.forceBootModeJtag = lib.mkDefault (config.plat == "zynqmp");
  };
}
