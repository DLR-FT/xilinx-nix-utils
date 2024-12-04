{
  lib,
  stdenvNoCC,
  coreutils-full,
}:

{ toolchain, platform }:

stdenvNoCC.mkDerivation (finalAttrs: {
  name = "check-commands-${toolchain.name}-${platform}";

  nativeBuildInputs = [
    coreutils-full
    toolchain
  ];

  dontUnpack = true;

  installPhase = ''
    mkdir --parent -- .
    bash ${./..}/commands/create-project ${lib.strings.escapeShellArg platform} work nix_test
    bash ${./..}/commands/build-hw-config work/nix_test
    bash ${./..}/commands/build-bootloader ${lib.strings.escapeShellArg platform} work/nix_test

    mv work "$out"
  '';
})
