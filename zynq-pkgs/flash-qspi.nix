{
  lib,
  writeScript,
  xilinx-unified-or-lab,

  name ? null,
  version ? null,

  bootImage,
  flashPart,
  initFsbl,
  offset ? null,
}@args:

let
  name = if args.name != null then args.name else "zynq-flash-qspi";
  version = if args.version != null then args.version else "unstable";

  file_args =
    files:
    lib.strings.concatStringsSep " " (
      lib.lists.zipListsWith (a: b: "${a} ${b}") [ "-file" "-sec_file" ] (lib.lists.toList files)
    );
in
writeScript "${name}.sh" ''
  #!/usr/bin/env sh

  # defaults for ${name} ${version}
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

  ${xilinx-unified-or-lab}/bin/vivado_lab -nolog -nojournal -mode batch -source ${../scripts/program-flash.tcl} -notrace -tclargs \
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
''
