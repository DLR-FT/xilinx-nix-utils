{ lib, ... }:
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
      type = with lib.types; singleLineStr;
      description = "Name of the firmware.";
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
  };

  config = {
  };
}
