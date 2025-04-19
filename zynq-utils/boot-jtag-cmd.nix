{
  lib,
  runCommand,
  writeScript,
}:

lib.makeOverridable (
  {
    hwplat,
    sdt,
    pmufw,
    fsbl,
    tfa,
    uboot,
    dtbLoadAddr ? "0x00100000",
    forceBootmodeJtag ? true,
  }:
  let
    baseName = hwplat.baseName;

    bootJtagScript = writeScript "boot-jtag-${baseName}.tcl" ''
      #!/usr/bin/env xsdb

      proc boot_jtag { } {
        ############################
        # Switch to JTAG boot mode #
        ############################
        targets -set -filter {name =~ "PSU"}
        # update multiboot to ZERO
        mwr 0xffca0010 0x0
        # change boot mode to JTAG
        mwr 0xff5e0200 0x0100
        # reset
        rst -system
      }

      connect
      target

      ${lib.strings.optionalString forceBootmodeJtag "boot_jtag"}
      after 2000

      targets -set -filter {name =~ "PSU"}

      # Download bitstream
      fpga ${hwplat.bit}

      # Select PMU
      mwr 0xffca0038 0x1FF
      targets -set -filter {name =~ "MicroBlaze PMU"}

      # Download pmufw
      dow ${pmufw.elf}
      con
      after 500

      # Select A53 Core 0
      targets -set -filter {name =~ "Cortex-A53 #0"}
      rst -processor -clear-registers

      # Download fsbl
      dow ${fsbl.elf}
      con
      after 3000
      stop

      # Download dtb + uboot
      dow -data ${sdt.dtb} ${dtbLoadAddr}
      dow ${uboot.elf}

      # Download atf
      dow ${tfa.elf}
      con
    '';
  in
  runCommand "boot-jtag-${baseName}" { } ''
    mkdir $out
    cp -- ${bootJtagScript} $out/boot-jtag-${baseName}.tcl
    ln -s $out/boot-jtag-${baseName}.tcl $out/boot-jtag.tcl
  ''
)
