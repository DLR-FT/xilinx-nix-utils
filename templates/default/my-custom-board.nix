{
  zynq-modules,
}:
zynq-modules.mkZynqFirmware {
  modules = [
    {
      # Mandatory: name of the firmware
      name = "kria-kr260";

      # Mandatory: plat zynq7 or zynqmp
      plat = "zynqmp";

      # Mandatory: exported (write_proejct_tcl) vivado project
      hwplat.src = ./vivado-srcs;

      # Mandatory: flash config
      flash-qspi = {
        flashPart = "mt25qu512-qspi-x4-single";
        offset = "0x00200000";
      };

      # Other options see: xilinx-nix-utils/zynq-modules/modules
    }
  ];
}
