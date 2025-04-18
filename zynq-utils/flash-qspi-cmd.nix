{ writeScript }:

{
  boot-image,
  fsbl,

  flashType,
  flashDensity,
  verify ? true,
}:
writeScript "flash-qspi.sh" ''
  #!/usr/bin/env sh

  program_flash -f ${boot-image.bin} -flash_type ${flashType} -fsbl ${fsbl.elf} -flash_density ${toString flashDensity} ${
    if verify then "-verify" else ""
  }
''
