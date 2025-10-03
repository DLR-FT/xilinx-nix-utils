# Xilinx Nix Utils

This repo provides a Nix package for the Xilinx Unfied Toolchain (Vivado, Vitis, xsdb, etc) as well as utilities for leveraging Nix as a build system for reliable, reproducibe and flexible Zynq (Zynq7, ZynqMP) Firmware builds.

## Getting Started

- Download Xilinx Unified Offline installer (tar): [Xilinx Unfied 2024.2](https://www.xilinx.com/support/download/index.html/content/xilinx/en/downloadNav/vivado-design-tools/2024-2.html)

- Add archive to the Nix store: `nix store add-file FPGAs_AdaptiveSoCs_Unified_2024.2_1113_1001.tar`

- `git clone https://github.com/DLR-FT/xilinx-nix-utils.git && cd xilinx-nix-utils`

- Enter DevShell: `nix develop`

- Build example Firmware Boot-Image (Kria KR260): `nix build .#fw`

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
./result/boot-jtag.tcl
```

- Flash QSPI:

```
nix build .#flash
./result/flash-qspi.sh
```

(For the Kria Starter Kit make sure Boot Image A is selected and marked as bootable in the [Recovery Firmware](https://xilinx.github.io/kria-apps-docs/bootfw/build/html/docs/bootfw_image_recovery.html))

## Overlays

This repo provides multiple Nix overlays for easy and flexible use:

- `overlays.xilinx-unified`: Contains Nix packages for the full (~100GB) Xilinx-Unfied Toolchain/IDE. Can be used standalone

- `overlays.xilinx-lab`: Contains Nix packages for the Xilinx-Lab tool. This tool can only be used for flashing, debugging, etc, but it is much smaller than the full Xilinx-Unified IDE. Can be used standalone

- `overlays.zynq-srcs`: Contains the Xilinx source repos for the Zynq Firmware components. For easy versioning and overrideability in a central place

- `overlays.zynq-utils`: Contains Nix packages for the Zynq Firmware components (PMUFW, FSBL, TF-A, U-Boot, etc) and utilities for building and deploying boot images. Depends on `zynq-srcs` and `default`

- `overlays.zynq-boards`: Contains complete example boards. Depends on `overlays.zynq-utils`

## DevShells

This flake provides three dev-shells:

- `default`: Provides only basic stuff, for development in this flake
- `xilinx-unified`: Provides the entire Xilinx-Unified Toolchain/IDE
- `xilinx-lab`: Provides the leightweight Xilinx-Lab tools. Can be used for debugging (xsdb), flashing, etc

## Example Flake

```
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs?ref=nixos-24.11";
    xlnx-utils.url = "github:moritz-meier/xilinx-nix-utils?ref=2024.2";
  };

  outputs =
    {
      self,
      nixpkgs,
      xlnx-utils,
    }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfree = true;

        overlays = [
          # For ARMv7A Cortex-A9 support; otherwise FSBL build will fail
          (final: prev: {
            pkgsCross = prev.pkgsCross // {
              armhf-embedded = import nixpkgs {
                localSystem = system;
                crossSystem = {
                  config = "arm-none-eabihf";
                  gcc.arch = "armv7-a+fp";
                  gcc.tune = "cortex-a9";
                };

                overlays = [

                  xlnx-utils.overlays.zynq-srcs
                  xlnx-utils.overlays.zynq-utils
                ];
              };
            };
          })

          # Lets add the overlays
          xlnx-utils.overlays.xilinx-unified
          xlnx-utils.overlays.xilinx-lab
          xlnx-utils.overlays.zynq-srcs
          xlnx-utils.overlays.zynq-utils
          xlnx-utils.overlays.zynq-boards

          # Zynq sources are overrideable; Lets override the U-Boot source
          (final: prev: {
            zynq-srcs = prev.zynq-srcs // {
              uboot-src = pkgs.fetchFromGitHub {
                owner = "Xilinx";
                repo = "u-boot-xlnx";
                rev = "xlnx_rebase_v2025.01";
                hash = "sha256-uN6oXoa6huclsz1c5Z2IyIvJoRfMr1QsfKF6Y2Z4zf4=";
              };
            };
          })
        ];
      };
    in
    {
      packages.${system} =
        let
          # Boards are overrideable: Lets override the U-Boot config:
          board = pkgs.zynq-boards.kria-kr260.overrideAttrs (final: prev {
            # Firmware components are overrideable as well:
            # (The derivations they produce are of course also overrideable with overrideAttrs)
            uboot = prev.uboot.override (prev: { extraConfig = prev.extraConfig + "CONFIG_FOO=y"; });
          });
        in
        {
          # A Board is just an attribute set of the firmware components and commands
          hwplat = board.hwplat; # This is the Zynq hardware platform (bitsteam, xsa)
          sdt = board.sdt; # This is the xilinx system-device-tree
          pmufw = board.pmufw; # This is the Microblaze PMU firmware (ZynqMP Only)
          fsbl = board.fsbl; # This is the First-Stage bootloader (BL2)
          tfa = board.tfa; # This is the ARM Trusted-Firmware-A (BL31)
          linux-dt = board.linux-dt; # This is the Linux device-tree for the Cortex-A; used in U-Boot
          uboot = board.uboot; # U-Boot (BL33)
          fw = board.boot-image; # This is the fully assembled boot image.
          boot = board.boot-jtag; # Script for booting the firmware components via JTAG
          flash = board.flash-qspi; # Script for downloading the boot image into QSPI flash.
        };

      devShells.${system}.default = pkgs.mkShell {
        packages = [
          pkgs.xilinx-unified
        ];
      };
    };
}
```

## Example Board

```
{
  zynq-utils,
}:
zynq-utils.zynqmp.board {
  name = "my-zynq-board";

  # Mandaory: Supply the exported (write_project_tcl) Vivado project
  hwplat = {
    src = ./vivado-srcs;
    # Optionally override the vivado source tcl file (default is vivado.tcl):
    # sourceTcl = ./vivado-srcs/vivado.tcl;
  };

  # Optional: Override Firmware components args
  linux-dt = {
    # Lets add an additional board device tree file
    extraDtsi = ./dts/board.dtsi;
  };

  uboot = {
    # Lets add some U-Boot configs
    extraConfig = ''
      CONFIG_LOG=y
      CONFIG_CMD_LOG=y
      CONFIG_LOG_DEFAULT_LEVEL=4
      CONFIG_LOG_MAX_LEVEL=7
      CONFIG_LOG_CONSOLE=y
    '';
  };

  boot-jtag = {
    forceBootModeJtag = true;
  };

  flash-qspi = {
    # Mandatory: Provide the QSPI flash type and density (see program_flash -help)
    flashType = "qspi-x4-single";
    flashDensity = 64;
  };
}

```
