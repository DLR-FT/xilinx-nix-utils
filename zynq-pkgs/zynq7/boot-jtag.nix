{
  writeScript,
  xilinx-unified-or-lab,

  name ? null,
  version ? null,

  hwplat,
  fsbl,
  uboot,
  dtbLoadAddr ? "0x00100000",
}@args:

let
  name = if args.name != null then args.name else "zynq-boot-jtag";
  version = if args.version != null then args.version else "unstable";
in
writeScript "${pname}-${version}.tcl" ''
  #!${xilinx-unified-or-lab}/bin/xsdb

  # Boot JTAG: ${pname} ${version}

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
  dow -data ${uboot.dtb} ${builtins.toString dtbLoadAddr}
  dow ${uboot.elf}

  con
''
