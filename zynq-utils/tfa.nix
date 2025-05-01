{
  dtc,
  lib,
  stdenv,
  zynq-srcs,
}:

lib.makeOverridable (
  {
    plat,
    extraMakeFlags ? [ ],
    extraPatches ? [ ],
    src ? zynq-srcs.tfa-src,
  }@args:
  stdenv.mkDerivation (finalAttrs: rec {
    name = "trusted-firmware-a-${plat}";
    version = src.rev;

    inherit src;

    nativeBuildInputs = [
      dtc
    ];

    makeFlags = [
      "CROSS_COMPILE=${stdenv.cc.targetPrefix}"
      "PLAT=${plat}"
    ] ++ extraMakeFlags;

    patches = [ ] ++ extraPatches;

    dontConfigure = true;

    buildPhase = ''
      runHook preBuild

      make ${(lib.strings.escapeShellArgs makeFlags)} -j $NIX_BUILD_CORES bl31

      runHook postBuild
    '';

    installPhase = ''
      runHook preInstall

      mkdir $out
      cp -r ./build/. $out/

      runHook postInstall
    '';

    dontFixup = true;

    passthru = {
      inherit args;
      elf = "${finalAttrs.finalPackage.out}/${plat}/release/bl31/bl31.elf";
    };
  })
)
