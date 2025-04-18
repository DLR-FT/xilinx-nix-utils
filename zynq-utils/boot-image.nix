{
  lib,
  stdenv,
  xilinx-unified,
}:

{
  prjName,
  fsbl,
  hwplat,
  pmufw,
  sdt,
  tfa,
  uboot,
}:
let
  boot_bif = ''
    the_ROM_image:
    {
      [bootloader, destination_cpu = a53-0] ${fsbl.elf}
      [pmufw_image] ${pmufw.elf}
      [destination_device = pl]  ${hwplat.bit}
      [destination_cpu = a53-0, exception_level = el-3, trustzone] ${tfa.elf}
      [destination_cpu = a53-0, exception_level = el-2] ${uboot.elf}
      [destination_cpu = a53-0,load = 0x00100000] ${sdt.dtb}
    }
  '';
in
stdenv.mkDerivation (finalAttrs: {
  name = "${prjName}-fw";

  nativeBuildInputs = [ xilinx-unified ];

  dontUnpack = true;
  dontPatch = true;
  doCheck = false;

  buildPhase = ''
    bootgen -arch zynqmp -image <(echo ${lib.strings.escapeShellArg boot_bif}) -w -o boot.bin
  '';

  installPhase = ''
    mkdir $out

    cp -- ${hwplat.bit} $out/
    cp -r -- ${sdt}/dt $out/dt
    cp -- ${pmufw.elf} $out/
    cp -- ${fsbl.elf} $out/
    cp -- ${tfa.elf} $out/
    cp -- ${uboot.elf} $out/

    cp -- boot.bin $out/boot.bin
  '';

  dontFixup = true;
  dontPatchELF = true;
  dontPatchShebangs = true;
  doInstallCheck = false;
  doDist = false;

  passthru = {
    bin = "${finalAttrs.finalPackage.out}/boot.bin";
  };
})
