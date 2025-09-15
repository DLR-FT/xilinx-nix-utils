{
  buildPackages,
  dtc,
  lib,
  stdenv,
  zynq-srcs,
}:

lib.makeOverridable (
  {
    # Platform name (zynqmp, ...)
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

    depsBuildBuild = [ buildPackages.stdenv.cc ];

    makeFlags = [
      "HOSTCC=$(CC_FOR_BUILD)"
      "CROSS_COMPILE=${stdenv.cc.targetPrefix}"
      "CC=${stdenv.cc.targetPrefix}cc"
      "LD=${stdenv.cc.targetPrefix}cc"
      "AS=${stdenv.cc.targetPrefix}cc"
      "OC=${stdenv.cc.targetPrefix}objcopy"
      "OD=${stdenv.cc.targetPrefix}objdump"

      "PLAT=${plat}"
    ]
    ++ extraMakeFlags;

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
