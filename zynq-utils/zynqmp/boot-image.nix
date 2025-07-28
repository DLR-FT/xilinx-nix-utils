{
  lib,
  stdenv,
  zynq-utils,
}:

lib.makeOverridable (
  {
    hwplat,
    pmufw,
    fsbl,
    tfa,
    uboot,
    # Optional: The address at which the dtb will be loaded
    dtbLoadAddr ? "0x00100000",
    # Optional: Generate boot-image for dual-qspi flash.
    # Either "parallel" or "stacked <size>".
    # See xilinx bootgen
    dualQspiMode ? null,
    # Optional: Boot image description (boot.bif)
    # Can include placeholders like %name%, %fslb%, %pmufw%, %bit%, etc
    bootBif ? null,
  }@args:
  let
    baseName = hwplat.baseName;
    toSnake = lib.strings.stringAsChars (ch: if ch == "-" then "_" else ch);

    defaultBootBif = ''
      @name@:
      {
        [bootloader, destination_cpu = a53-0] @fsbl@
        [pmufw_image] @pmufw@
        [destination_device = pl] @bit@
        [destination_cpu = a53-0, exception_level = el-3, trustzone] @tfa@
        [destination_cpu = a53-0, exception_level = el-2] @uboot@
        [destination_cpu = a53-0, load = @dtbLoadAddr@] @dtb@
      }
    '';
  in
  stdenv.mkDerivation (finalAttrs: {
    name = "${baseName}-boot-image";

    nativeBuildInputs = [ zynq-utils.bootgen ];

    dontUnpack = true;
    dontPatch = true;

    buildPhase = ''
      runHook preBuild

      echo ${lib.strings.escapeShellArg (if bootBif != null then bootBif else defaultBootBif)} > boot.bif
      substituteInPlace ./boot.bif \
        --subst-var-by "name" ${toSnake baseName} \
        --subst-var-by "fsbl" ${fsbl.elf} \
        --subst-var-by "pmufw" ${pmufw.elf} \
        --subst-var-by "bit" ${hwplat.bit} \
        --subst-var-by "tfa" ${tfa.elf} \
        --subst-var-by "uboot" ${uboot.elf} \
        --subst-var-by "dtb" ${uboot.dtb} \
        --subst-var-by "dtbLoadAddr" ${dtbLoadAddr}

      bootgen -arch zynqmp \
        -image ./boot.bif \
        ${lib.strings.optionalString (!builtins.isNull dualQspiMode) "-dual_qspi_mode ${dualQspiMode}"} \
        -w -o boot.bin

      runHook preBuild
    '';

    installPhase = ''
      runHook preInstall

      mkdir $out
      cp -- boot.bif $out/boot.bif
      cp -- boot*.bin $out/

      runHook postInstall
    '';

    dontFixup = true;

    passthru = {
      inherit args baseName;
      bif = "${finalAttrs.finalPackage.out}/boot.bif";
      bin =
        if builtins.pathExists "${finalAttrs.finalPackage.out}/boot_1.bin" then
          [
            "${finalAttrs.finalPackage.out}/boot_1.bin"
            "${finalAttrs.finalPackage.out}/boot_2.bin"
          ]
        else
          "${finalAttrs.finalPackage.out}/boot.bin";
    };
  })
)
