{
  lib,
  runCommand,
  writeScript,
}:

lib.makeOverridable (
  {
    bootImage,
    # FSBL used for flashing the boot image
    # In most cases this can be the same as the fsbl in the boot image
    # Only for Zynq7 devices which cannnot be physically switched into JTAG boot mode
    # a modified FSBL is necessary.
    # (https://adaptivesupport.amd.com/s/article/70548?language=en_US)
    dowFsbl,
    # Flash type (qspi-x4-single, ...)
    # (see program_flash -help)
    flashType,
    # Flash density
    # (see program_flash -help)
    flashDensity,
    # Optional: Verify after download
    verify ? true,
    # Optional extra args for program_flash
    extraArgs ? [ ],
  }:
  let
    baseName = bootImage.baseName;

    flashQspiScript = writeScript "flash-qspi-${baseName}.sh" ''
      #!/usr/bin/env sh

      program_flash \
        -f ${bootImage.bin} \
        -flash_type ${flashType} \
        -fsbl ${dowFsbl.elf} \
        -flash_density ${toString flashDensity} \
        ${lib.strings.optionalString verify "-verify"} \
        ${lib.strings.concatStringsSep " " extraArgs}
    '';
  in
  runCommand "flash-qspi-${baseName}" { } ''
    mkdir $out
    cp -- ${flashQspiScript} $out/flash-qspi-${baseName}.sh
    ln -s $out/flash-qspi-${baseName}.sh $out/flash-qspi.sh
  ''
)
