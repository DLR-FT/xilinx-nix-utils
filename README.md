# Xilinx Nix Utils

This repo provides a Nix package for the Xilinx Unfied Toolchain (Vivado, Vitis, xsdb, etc) as well as utilities for leveraging Nix as a build system for reliable, reproducibe and flexible Zynq (Zynq7, ZynqMP) Firmware builds.

## Getting Started

- Download Xilinx Unified Offline installer (tar): [Xilinx Unfied 2025.1](https://www.xilinx.com/support/download/index.html/content/xilinx/en/downloadNav/vivado-design-tools/2025-1.html)

- Add archive to the Nix store: `nix store add-file FPGAs_AdaptiveSoCs_Unified_SDI_2025.1_0530_0145.tar`

- `git clone https://github.com/DLR-FT/xilinx-nix-utils.git && cd xilinx-nix-utils`

- Enter DevShell: `nix develop`

- Build example Firmware Boot-Image (Kria KR260): `nix build .#kria-kr260`

- Install Udev rules for Xilinx FTDI JTAG/Serial Probe:

```
$ lsusb
...
Bus 004 Device 009: ID 0403:6010 Future Technology Devices International, Ltd FT2232C/D/H Dual UART/FIFO IC
...
```

`/etc/udev/rules.d/69-ftdi.rules`: must be loaded before `73-seat-late.rules` in order for `uaccess` to work ([arch wiki](https://wiki.archlinux.org/title/Udev#Allowing_regular_users_to_use_devices))

```
ATTRS{idVendor}=="0403", ATTRS{idProduct}=="6010", TAG+="uaccess"
ATTRS{idVendor}=="0403", ATTRS{idProduct}=="6011", TAG+="uaccess"
ATTRS{idVendor}=="0403", ATTRS{idProduct}=="6014", TAG+="uaccess"
...
```

- Boot via JTAG

```
nix build .#boot
./result/kria-kr260-boot-jtag.tcl
```

- Flash QSPI:

```
nix build .#flash
./result/kria-kr260-flash-qspi.sh
```

(For the Kria Starter Kit make sure Boot Image A is selected and marked as bootable in the [Recovery Firmware](https://xilinx.github.io/kria-apps-docs/bootfw/build/html/docs/bootfw_image_recovery.html))

## Overlays

This repo provides multiple Nix overlays for easy and flexible use:

- `overlays.xilinx-unified`: Contains Nix packages for the full (~100GB) Xilinx-Unfied Toolchain/IDE. Can be used standalone

- `overlays.xilinx-lab`: Contains Nix packages for the Xilinx-Lab tool. This tool can only be used for flashing, debugging, etc, but it is much smaller than the full Xilinx-Unified IDE. Can be used standalone

- `overlays.zynq-srcs`: Contains the Xilinx source repos for the Zynq Firmware components. For easy versioning and overrideability in a central place.

- `overlays.zynq-pkgs`: Contains Nix packages for the Zynq Firmware components (PMUFW, FSBL, TF-A, U-Boot, etc) and utilities for building and deploying boot images.

- `overlays.zynq-modules`: Contains Nix Modules for configuring and building Zynq firmware.

- `overlays.zynq-boards`: Contains complete, reusable example boards.

## DevShells

This flake provides three dev-shells:

- `default`: Provides only basic stuff, for development in this flake
- `xilinx-unified`: Provides the entire Xilinx-Unified Toolchain/IDE
- `xilinx-lab`: Provides the leightweight Xilinx-Lab tools. Can be used for debugging (xsdb), flashing, etc

## Example Flake

See `./templates/` for full example.
