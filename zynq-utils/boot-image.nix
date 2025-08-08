{
  lib,
  stdenv,
  zynq-utils,
}:

lib.makeOverridable (
  {
    baseName,
    arch,
    bootBif,
    # Optional: Generate boot-image for dual-qspi flash.
    # Either "parallel" or "stacked <size>".
    # See xilinx bootgen
    dualQspiMode ? null,
    extraArgs ? [ ],
  }@args:
  stdenv.mkDerivation (finalAttrs: {
    name = "${baseName}-boot-image";

    nativeBuildInputs = [ zynq-utils.bootgen ];

    dontUnpack = true;
    dontPatch = true;

    buildPhase = ''
      runHook preBuild

      ${
        if builtins.isPath bootBif then
          ''
            cp -- ${bootBif} ./boot.bif
          ''
        else
          ''
            echo ${lib.strings.escapeShellArg bootBif} > ./boot.bif
          ''
      }

      bootgen -arch ${arch} \
        -image ./boot.bif \
        ${lib.strings.optionalString (!builtins.isNull dualQspiMode) "-dual_qspi_mode ${dualQspiMode}"} \
        ${lib.strings.concatStringsSep " " extraArgs} \
        -w -o boot.bin \

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
