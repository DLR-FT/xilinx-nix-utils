{
  zynq-modules,
}:
zynq-modules.mkZynqFirmware {
  modules = [
    (
      { config, ... }:
      {
        # Mandatory: Firmware name
        name = "kria-kr260";

        # Mandatory: Target platform, either Zynq-7000 (zynq7) or Zynq-Ultrascale (zynqmp)
        plat = "zynqmp";

        # Mandatory: Vivado project for the hardware-platform and bitstream
        # hwplat.src = ./vivado-srcs;

        # Include static, dev-board specific .dtsi (see github:Xilinx/system-device-tree-xlnx)
        # sdt.boardDts = "<board-dts-name>";

        # Include user-defined .dtsi (see github:Xilinx/system-device-tree-xlnx)
        # sdt.extraDtsi = ./board.dtsi;

        # Add extra lops to convert system-device-tree to linux-device-tree (see github:devicetree-org/lopper)
        linux-dt.extraLops = [ ];

        # Add extra .dtsi files to include in the linux dtb.
        linux-dt.extraDtsi = [ ];

        # Add extra make flags to the trusted-firmware-a build
        tfa.extraMakeFlags = [ ];

        # Enable optee-os (BL32, secure operating-system)
        optee-os.enable = true;

        # Add extra make flags to u-boot build
        uboot.extraMakeFlags = [ ];

        # Add extra config options to u-boot
        uboot.extraConfigs = [ ];

        # Overwrite boot bif
        boot-image.bootBif = ''
          custom-bootimage:
            {
              [bootloader, destination_cpu = a53-0] ${config.fsbl.package.elf}
              [pmufw_image] ${config.pmufw.package.elf}
              [destination_device = pl] ${config.hwplat.package.bit}
              [destination_cpu = a53-0, exception_level = el-3, trustzone] ${config.tfa.package.elf}
              [destination_cpu = a53-0, exception_level = el-2] ${config.uboot.package.elf}
              [destination_cpu = a53-0, load = 0x00100000] ${config.linux-dt.package.dtb}
            }
        '';

        # Set dtb load addr
        boot-jtag.dtbLoadAddr = "0x00100000";

        # Force SoC into JTAG boot mode before booting via JTAG
        boot-jtag.forceBootModeJtag = true;

        # Mandatory: Flash part number
        flash-qspi.flashPart = "mt25qu512-qspi-x4-single";

        # Set flash offset
        flash-qspi.offset = "0x0";

        # For more config options see xilinx-nix-utils/zynq-modules
      }
    )
  ];
}
