# Xilinx Nix Utils

This repo provides a Nix package for the Xilinx Unfied Toolchain (Vivado, Vitis, xsdb, etc) as well as utilities for leveraging Nix as a build system for reliable, reproducibe and flexible Zynq (Zynq7, ZynqMP) Firmware builds.

## Getting Started

- Download Xilinx Unified Offline installer (tar): [Xilinx Unfied 2025.2](https://www.xilinx.com/support/download/index.html/content/xilinx/en/downloadNav/vivado-design-tools/2025-2.html)

- Add archive to the Nix store:

```
nix store add-file $(realpath ~Downloads/FPGAs_AdaptiveSoCs_Unified_SDI_2025.2_1114_2157.tar)
```

- Clone this repo:

```
git clone https://github.com/DLR-FT/xilinx-nix-utils.git
cd xilinx-nix-utils
```

- Build example Firmware (Kria KR260):

```
nix build .#kria-kr260 --print-build-logs
# ...

ls -lah ./result/
# kria-kr260-boot-image ⇒ /nix/store/qbqkbw2qpn8fz0ld8i0w98921dlq5ias-kria-kr260-boot-image
# kria-kr260-boot-jtag.sh ⇒ /nix/store/r0qcz7n0bicvlzzlacv6j62akcpylnqv-kria-kr260-boot-jtag.sh
# kria-kr260-config.json ⇒ /nix/store/fn84xxi0lgqyjmn54d6rqnrkmlhfkib7-kria-kr260-config.json
# kria-kr260-flash-qspi.sh ⇒ /nix/store/ksfjgc3zgaci0drw460al1b2k3k377dl-kria-kr260-flash-qspi.sh
# kria-kr260-fsbl-aarch64-none-elf ⇒ /nix/store/8w1in1rcjn51zgp1lb8xbsb8k3x1lw0m-kria-kr260-fsbl-aarch64-none-elf
# kria-kr260-hwplat ⇒ /nix/store/5qb87c9a2qpq0dqx09zil8ryjrmmizaq-kria-kr260-hwplat
# kria-kr260-linux-dt ⇒ /nix/store/ds1r6svlmy8h7zw3pyyhq6m2gcj0j35j-kria-kr260-linux-dt
# kria-kr260-optee-os-aarch64-unknown-linux-gnu ⇒ /nix/store/7b5771gxzja699q5jn12m8pn589qx1rb-kria-kr260-optee-os-aarch64-unknown-linux-gnu
# kria-kr260-pmufw-microblazeel-none-elf ⇒ /nix/store/1r8jlmw0g8mbzrxv2jd0k240fym6by2s-kria-kr260-pmufw-microblazeel-none-elf
# kria-kr260-sdt ⇒ /nix/store/fafy1bbh7ccy8y89bhc66gmjcl02yvp9-kria-kr260-sdt
# kria-kr260-tfa-aarch64-unknown-linux-gnu ⇒ /nix/store/x5rhjrj58r1kkwmdp2pfhc635agqs5b4-kria-kr260-tfa-aarch64-unknown-linux-gnu
# kria-kr260-uboot-aarch64-unknown-linux-gnu ⇒ /nix/store/5phrr7b2r9sl86rwkydckwbp8v2cs15y-kria-kr260-uboot-aarch64-unknown-linux-gnu

```

- Install Udev rules for Xilinx FTDI JTAG/Serial Probe:  
  (must be loaded before `73-seat-late.rules` in order for `uaccess` to work: [arch wiki](https://wiki.archlinux.org/title/Udev#Allowing_regular_users_to_use_devices))

```
$ lsusb
#...
# Bus 004 Device 009: ID 0403:6010 Future Technology Devices International, Ltd FT2232C/D/H Dual UART/FIFO IC
# ...
```

e.g. `/etc/udev/rules.d/69-ftdi.rules`:

```
ATTRS{idVendor}=="0403", ATTRS{idProduct}=="6010", TAG+="uaccess"
ATTRS{idVendor}=="0403", ATTRS{idProduct}=="6011", TAG+="uaccess"
ATTRS{idVendor}=="0403", ATTRS{idProduct}=="6014", TAG+="uaccess"
# ...
# or to allow all uaccess for all ftdi device:
ATTRS{idVendor}=="0403", ENV{ID_USB_DRIVER}=="ftdi_sio", TAG+="uaccess"
```

- Boot firmware via JTAG (See `-help` for extra options):

```
./result/kria-kr260-boot-jtag.sh
```

- Flash firmware to QSPI Flash:

```
./result/kria-kr260-flash-jtag.sh
```

(For the Kria Starter Kit make sure Boot Image A is selected and marked as bootable in the [Recovery Firmware](https://xilinx.github.io/kria-apps-docs/bootfw/build/html/docs/bootfw_image_recovery.html))

## Overlays

This repo provides multiple Nix overlays for easy and flexible use:

- `overlays.xilinx-unified`: Contains packages for the full (~100GB) Xilinx-Unfied Toolchain/IDE.

- `overlays.xilinx-lab`: Contains packages for the Xilinx-Lab tool. This tool can only be used for flashing, debugging, etc, but it is much smaller than the full Xilinx-Unified IDE.

- `overlays.zynq-srcs`: Contains the Xilinx source repos for the Zynq Firmware components. For easy versioning and overrideability in a central place.

- `overlays.zynq-patches`: Contains necessary patches for the Zynq source repos to iron out some Xilinx problems.

- `overlays.zynq-pkgs`: Contains packages for the Zynq Firmware components (PMUFW, FSBL, TF-A, U-Boot, etc) and utilities for building and deploying boot images.

- `overlays.zynq-modules`: Contains Nix Modules for configuring and building Zynq firmware.

- `overlays.zynq-boards`: Contains firmware configs for certain boards.

## DevShells

This flake provides three dev-shells:

- `default`: Provides only basic stuff, for development in this flake
- `xilinx-unified`: Provides the entire Xilinx-Unified Toolchain/IDE
- `xilinx-lab`: Provides the leightweight Xilinx-Lab tools. Can be used for debugging (xsdb), flashing, etc

## Examples

See `./templates/` for full examples.

```
nix flake init -t github:dlr-ft/xilinx-nix-utils
```
