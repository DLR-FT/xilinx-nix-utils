{
  lib,
  runCommand,
  writeScript,
  xilinx-common,
}:

lib.makeOverridable (
  {
    bootImage,

    # Flash part e.g. mt25qu512-qspi-x4-single, ...
    # Use program-flash.tcl -flash "" to get known flash parts
    # See vivado tcl function "get_cfgmem_parts"
    flashPart,

    # FSBL used for initializing the hw before flashing
    # In most cases this can be the same as the fsbl in the boot image
    # Only for Zynq7 devices which cannnot be physically switched into JTAG boot mode
    # a modified FSBL is necessary.
    # (https://adaptivesupport.amd.com/s/article/70548?language=en_US)
    initFsbl,

    # Optional: Offset at which the image is flashed
    offset ? null,
  }:
  let
    baseName = bootImage.baseName;

    flashQspiScript = writeScript "flash-qspi-${baseName}.sh" ''
      #!/usr/bin/env sh

      # defaults for ${baseName}
      target="*" # the jtag probe, default is the first one
      device="*" # the device in the jtag chain, default is the first one
      flash_part="${flashPart}"
      addr_range="use_file" # either "use_file" or "entire_device"
      bin_offset="${
        if (offset != null) then (builtins.toString offset) else "0"
      }" # offset at which the image is flashed
      erase=1
      blank_check=0
      program=1
      verify=1

      while [ "$#" -gt 0 ]; do
        case $1 in
          -target) target="$2"; shift;;
          -device) device="$2"; shift;;
          -flash_part) flash_part="$2"; shift;;
          -addr_range) addr_range="$2"; shift;;
          -bin_offset) bin_offset="$2"; shift;;
          -erase) erase="$2"; shift;;
          -blank_check) blank_check="$2"; shift;;
          -program) program="$2"; shift;;
          -verify) verify="$2"; shift;;
          *) echo "Unknown arg: $1"; exit 1;;
        esac
        shift
      done

      ${xilinx-common}/bin/vivado_lab -nolog -nojournal -mode batch -source ${../scripts/program-flash.tcl} -notrace -tclargs \
        -target "$target" \
        -device "$device" \
        -flash_part "$flash_part" \
        -addr_range "$addr_range" \
        -bin_offset "$bin_offset" \
        -erase "$erase" \
        -blank_check "$blank_check" \
        -program "$program" \
        -verify "$verify" \
        -zynq_fsbl ${initFsbl.elf} \
        ${file_args bootImage.bin}
    '';

    file_args =
      files:
      lib.strings.concatStringsSep " " (
        lib.lists.zipListsWith (a: b: "${a} ${b}") [ "-file" "-sec_file" ] (lib.lists.toList files)
      );
  in
  runCommand "flash-qspi-${baseName}" { } ''
    mkdir $out

    ln -s ${../scripts/program-flash.tcl} $out/program-flash.tcl
    ln -s ${flashQspiScript} $out/flash-qspi-${baseName}.sh
  ''
)
