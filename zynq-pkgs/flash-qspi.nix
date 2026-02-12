{
  lib,
  writeScript,
  xilinx-unified-or-lab,

  name ? null,
  version ? null,

  bootImages,
  initFsbl,
  flashPart,
  offset ? null,
}@args:

let
  name = if args.name != null then args.name else "zynq-flash-qspi";
  version = if args.version != null then args.version else "unstable";
in
writeScript "${name}.sh" ''
  #!/usr/bin/env sh

  usage() {
    echo "${name} ${version}"
    echo "Optional args: "
    echo "-url <url>                            Specifies the url of the hw_server. Start a new local hw_server if empty."
    echo "-target <name>                        Specifies the target (debug adapter) used for programming. Use '*' to select any / the first one."
    echo "-device <name>                        Specifies the device (in the JTAG chain) used for programming. Use '*' to select any / the first one."
    echo "-flash_part <name>                    Specifies the flash part / type to program. Use '*' to show known parts."
    echo "-addr_range [use_file, entire_device] Specifies the address range to programm."
    echo "-bin_offset <offset>                  Specifies the offset at which the image will be flashed."
    echo "-erase <boolean>                      Specifies to erase the flash."
    echo "-blank_check <boolean>                Specifies to check the that the flash is blank."
    echo "-program <boolean>                    Specifies to program the flash with the supplied image."
    echo "-verify <boolean>                     Specifies to verify the flash content after programming."
    echo "-zynq_fsbl <*.elf>                    Specifies the first-stage bootloader image for initializing the hardware."
    echo "-file <*.bin>                         Specifies the binary image to flash."
    echo "-sec_file <*.bin>                     Specifies an optional second binary image to flash for parallel or stacked flash configurations."
  }

  url=""
  target="*"
  device="*"
  flash_part="${flashPart}"
  addr_range="use_file"
  bin_offset="${if (offset != null) then (builtins.toString offset) else "0"}"
  erase=1
  blank_check=0
  program=1
  verify=1
  zynq_fsbl="${lib.escapeShellArg initFsbl}"

  file=""
  sec_file=""

  ${lib.strings.concatStringsSep "\n" (
    lib.lists.zipListsWith (a: b: "${a}=\"${lib.escapeShellArg b}\"") [ "file" "sec_file" ] (
      lib.lists.toList bootImages
    )
  )}

  while [ "$#" -gt 0 ]; do
    case $1 in
      -url) url="$2";                 shift;;
      -target) target="$2";           shift;;
      -device) device="$2";           shift;;
      -flash_part) flash_part="$2";   shift;;
      -addr_range) addr_range="$2";   shift;;
      -bin_offset) bin_offset="$2";   shift;;
      -erase) erase="$2";             shift;;
      -blank_check) blank_check="$2"; shift;;
      -program) program="$2";         shift;;
      -verify) verify="$2";           shift;;
      -file) file="$2";               shift;;
      -sec_file) sec_file="$2";       shift;;
      -help) usage;                   exit 0;;
      *) echo "Unknown arg: $1";      exit 1;;
    esac
    shift
  done

  exit 13

  ${xilinx-unified-or-lab}/bin/vivado_lab -nolog -nojournal -mode batch -source ${../scripts/program-flash.tcl} -notrace -tclargs \
    -url "$url" \
    -target "$target" \
    -device "$device" \
    -flash_part "$flash_part" \
    -addr_range "$addr_range" \
    -bin_offset "$bin_offset" \
    -erase "$erase" \
    -blank_check "$blank_check" \
    -program "$program" \
    -verify "$verify" \
    -zynq_fsbl "$zynq_fsbl" \
    -file "$file" \
    -sec_file "$sec_file"
''
