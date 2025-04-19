{
  lib,
  runCommand,
  writeScript,
}:

lib.makeOverridable (
  {
    bootImage,
    dowFsbl,
    flashType,
    flashDensity,
    verify ? true,
    extraArgs ? [ ],
  }:
  let
    baseName = bootImage.baseName;

    flashSpiScript = writeScript "flash-qspi-${baseName}.sh" ''
      #!/usr/bin/env sh

      program_flash \
        -f ${bootImage.bin} \
        -flash_type ${flashType} \
        -fsbl ${dowFsbl.elf} \
        -flash_density ${toString flashDensity} \
        ${lib.strings.optionalString verify "-verify \\"}
        ${lib.strings.concatStringsSep " " extraArgs}
    '';
  in
  runCommand "flash-qspi-${baseName}" { } ''
    mkdir $out
    cp -- ${flashSpiScript} $out/flash-qspi-${baseName}.sh
    ln -s $out/flash-qspi-${baseName}.sh $out/flash-qspi.sh
  ''
)
