{
  lib,
  stdenv,
  xilinx-unified,
}:

lib.makeOverridable (
  {
    hwplat,
    fsbl,
    linux-dt,
    uboot,

    dtbLoadAddr ? "0x00100000",
    bootBif ? null,
  }@args:
  let
    baseName = hwplat.baseName;
    toSnake = lib.strings.stringAsChars (ch: if ch == "-" then "_" else ch);

    defaultBootBif = ''
      @name@:
      {
        [bootloader] @fsbl@
        @bit@
        @uboot@
        [load = @dtbLoadAddr@] @dtb@
      }
    '';
  in
  stdenv.mkDerivation (finalAttrs: {
    name = "${baseName}-boot-image";

    nativeBuildInputs = [ xilinx-unified ];

    dontUnpack = true;
    dontPatch = true;

    buildPhase = ''
      runHook preBuild

      echo ${lib.strings.escapeShellArg (if bootBif != null then bootBif else defaultBootBif)} > boot.bif
      substituteInPlace ./boot.bif \
        --subst-var-by "name" ${toSnake baseName} \
        --subst-var-by "fsbl" ${fsbl.elf} \
        --subst-var-by "bit" ${hwplat.bit} \
        --subst-var-by "uboot" ${uboot.elf} \
        --subst-var-by "dtb" ${linux-dt.dtb} \
        --subst-var-by "dtbLoadAddr" ${dtbLoadAddr}

      bootgen -arch zynq -image ./boot.bif -w -o boot.bin

      runHook preBuild
    '';

    installPhase = ''
      runHook preInstall

      mkdir $out
      cp -- boot.bif $out/boot.bif
      cp -- boot.bin $out/boot.bin

      runHook postInstall
    '';

    dontFixup = true;

    passthru = {
      inherit args baseName;
      bif = "${finalAttrs.finalPackage.out}/boot.bif";
      bin = "${finalAttrs.finalPackage.out}/boot.bin";
    };
  })
)
