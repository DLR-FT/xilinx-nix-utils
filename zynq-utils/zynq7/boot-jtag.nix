{
  lib,
  runCommand,
  writeScript,
  xilinx-unified-or-lab,
}:

lib.makeOverridable (
  {
    hwplat,
    fsbl,
    uboot,
    # Optional: The address at which the dtb will be loaded
    dtbLoadAddr ? "0x00100000",
  }:
  let
    baseName = hwplat.baseName;

    bootJtagScript = writeScript "boot-jtag-${baseName}.tcl" ''
      #!${xilinx-unified-or-lab}/bin/xsdb

      connect
      target

      after 500

      targets -set -filter {name =~ "APU"}

      # Download bitstream
      fpga ${hwplat.bit}

      # Select A9 Core 0
      targets -set -filter {name =~ "ARM Cortex-A9 MPCore #0"}
      rst -processor -clear-registers

      # Download fsbl
      dow ${fsbl.elf}
      con
      after 5000; stop

      # Download dtb + uboot
      dow -data ${uboot.dtb} ${dtbLoadAddr}
      dow ${uboot.elf}

      con
    '';
  in
  runCommand "boot-jtag-${baseName}" { } ''
    mkdir $out
    cp -- ${bootJtagScript} $out/boot-jtag-${baseName}.tcl
    ln -s $out/boot-jtag-${baseName}.tcl $out/boot-jtag.tcl
  ''
)
