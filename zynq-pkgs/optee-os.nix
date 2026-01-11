{
  buildPackages,
  dtc,
  lib,
  stdenv,
  zynq-srcs,

  name ? null,
  version ? null,
  src ? zynq-srcs.optee-os-src,

  plat,
  extraMakeFlags ? [ ],
  extraPatches ? [ ],
}:

let
  _name = name;
  _version = version;
in
stdenv.mkDerivation (finalAttrs: rec {
  name = if _name != null then _name else "zynq-optee-os";
  version =
    if _version != null then
      _version
    else if (finalAttrs.src ? rev) then
      finalAttrs.src.rev
    else
      "";

  inherit src;

  nativeBuildInputs = [
    dtc
    # https://github.com/NixOS/nixpkgs/issues/305858
    (buildPackages.python3.withPackages (
      p: with p; [
        pyelftools
        cryptography
      ]
    ))
  ];

  depsBuildBuild = [ buildPackages.stdenv.cc ];

  makeFlags =
    let
      targetArch =
        {
          "arm" = "ta_arm32";
          "arm64" = "ta_arm64";
        }
        .${stdenv.hostPlatform.linuxArch};

      inherit (stdenv.hostPlatform) is32bit is64bit;
    in
    [
      "PLATFORM=${plat}"
      "CFG_USER_TA_TARGETS=${targetArch}"
      "O=./build"
    ]
    ++ (lib.optionals is32bit [
      "CFG_ARM32_core=y"
      "CROSS_COMPILE32=${stdenv.cc.targetPrefix}"
    ])
    ++ (lib.optionals is64bit [
      "CFG_ARM64_core=y"
      "CROSS_COMPILE64=${stdenv.cc.targetPrefix}"
    ])
    ++ extraMakeFlags;

  patches = [ ] ++ extraPatches;

  postPatch = ''
    patchShebangs $(find -type d -name scripts -printf '%p ')
  '';

  dontConfigure = true;

  buildPhase = ''
    runHook preBuild

    make ${(lib.strings.escapeShellArgs makeFlags)} -j $NIX_BUILD_CORES

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
    elf = "${finalAttrs.finalPackage.out}/core/tee.elf";
  };
})
