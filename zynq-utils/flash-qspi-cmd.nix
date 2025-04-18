{ writeScript }:

{
  boot-image,
  fsbl,
  flash-type,
  flash-density,
  verify ? true,
}:
writeScript "flash-qspi.sh" ''
  #!/usr/bin/env sh

  program_flash -f ${boot-image.bin} -flash_type ${flash-type} -fsbl ${fsbl.elf} -flash_density ${toString flash-density} ${
    if verify then "-verify" else ""
  }
''
