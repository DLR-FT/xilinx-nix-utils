{
  lib,
  stdenv,
  xilinx-unified,
}:

{
  prj-name,
  hw,
  sdt,
  pmufw,
  fsbl,
  atf,
  uboot,
}:
let
  boot_bif = ''
    the_ROM_image:
    {
      [bootloader, destination_cpu = a53-0] ${fsbl.elf}
      [pmufw_image] ${pmufw.elf}
      [destination_device = pl]  ${hw.bit}
      [destination_cpu = a53-0, exception_level = el-3, trustzone] ${atf.elf}
      [destination_cpu = a53-0, exception_level = el-2] ${uboot.elf}
      [destination_cpu = a53-0,load = 0x00100000] ${sdt.dtb}
    }
  '';
in
stdenv.mkDerivation (finalAttrs: {
  name = "${prj-name}-fw";

  nativeBuildInputs = [ xilinx-unified ];

  dontUnpack = true;
  dontPatch = true;
  doCheck = false;

  buildPhase = ''
    bootgen -arch zynqmp -image <(echo ${lib.strings.escapeShellArg boot_bif}) -w -o boot.bin
  '';

  installPhase = ''
    mkdir $out

    cp -- ${hw.bit} $out/
    cp -r -- ${sdt}/dt $out/dt
    cp -- ${pmufw.elf} $out/
    cp -- ${fsbl.elf} $out/
    cp -- ${atf.elf} $out/
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
