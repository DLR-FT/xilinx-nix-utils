{
  lib,
  writeScript,
  xilinx-unified-or-lab,

  name ? null,
  version ? null,

  plat,
  forceBootModeJtag ? null,
  bit ? null,
  pmufw ? null,
  fsbl ? null,
  tfa ? null,
  dtb ? null,
  uboot ? null,
  dtbAddr ? null,
}@args:

let
  name = if args.name != null then args.name else "zynq-boot-jtag";
  version = if args.version != null then args.version else "unstable";
in
writeScript "${name}.sh" ''
  #!/usr/bin/env sh

  # ${name} ${version}


  url=""
  force_bootmode_jtag="${
    lib.optionalString (forceBootModeJtag != null) lib.escapeShellArg forceBootModeJtag
  }"
  bit="${lib.escapeShellArg (lib.optionalString (bit != null) bit)}"
  pmufw="${lib.escapeShellArg (lib.optionalString (plat == "zynqmp" && pmufw != null) pmufw)}"
  fsbl="${lib.escapeShellArg (lib.optionalString (fsbl != null) fsbl)}"
  fsbl_target=""
  tfa="${lib.escapeShellArg (lib.optionalString (plat == "zynqmp" && tfa != null) tfa)}"
  dtb="${lib.escapeShellArg (lib.optionalString (dtb != null) dtb)}"
  dtb_addr="${lib.escapeShellArg (lib.optionalString (dtbAddr != null) (builtins.toString dtbAddr))}"
  uboot="${lib.escapeShellArg (lib.optionalString (uboot != null) uboot)}"
  target=""

  while [ "$#" -gt 0 ]; do
    case $1 in
      -url) url="$2";                                 shift;;
      -force_bootmode_jtag) force_bootmode_jtag="$2"; shift;;
      -bit) bit="$2";                                 shift;;
      -fsbl) fsbl="$2";                               shift;;
      -fsbl_target) fsbl_target="$2";                 shift;;
      -dtb) dtb="$2";                                 shift;;
      -dtb_addr) dtb_addr="$2";                       shift;;
      -uboot) uboot="$2";                             shift;;
      -target) target="$2";                           shift;;
      *) echo "Unknown arg: $1";                      exit 1;;
    esac
    shift
  done

  ${xilinx-unified-or-lab}/bin/xsdb -quiet ${../scripts/boot-jtag.tcl} \
    -url "$url" \
    -plat "${plat}" \
    -force_bootmode_jtag "$force_bootmode_jtag" \
    -bit "$bit" \
    ${lib.optionalString (plat == "zynqmp") "-pmufw \"$pmufw\""} \
    -fsbl "$fsbl" \
    -fsbl_target "$fsbl_target" \
    ${lib.optionalString (plat == "zynqmp") "-tfa \"$tfa\""} \
    -dtb "$dtb" \
    -dtb_addr "$dtb_addr" \
    -uboot "$uboot" \
    -target "$target"
''
