{
  writeScript,
  xilinx-unified-or-lab,

  name ? null,
  version ? null,

  hwplat,
  fsbl,
  uboot,
  dtbLoadAddr ? "0x00100000",
}:

let
  _name = if name != null then name else "zynq-boot-jtag";
  _version = if version != null then version else "";
in
writeScript "${_name}.tcl" ''
  #!${xilinx-unified-or-lab}/bin/xsdb

  # Boot JTAG: ${_name} ${_version}

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
