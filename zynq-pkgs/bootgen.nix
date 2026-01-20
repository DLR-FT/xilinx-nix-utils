{
  lib,
  openssl,
  stdenv,
  zynq-srcs,
}:
stdenv.mkDerivation (finalAttrs: {
  name = "bootgen";
  version = if (finalAttrs.src ? rev) then finalAttrs.src.rev else "unstable";

  src = zynq-srcs.bootgen-src;

  buildInputs = [
    openssl
  ];

  makeFlags = [
    "CROSS_COMPILE=${stdenv.cc.targetPrefix}"
  ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin
    [ -f ./bootgen ] && cp -- ./bootgen $out/bin
    [ -f ./build/bin/bootgen ] && cp -- ./build/bin/bootgen $out/bin

    runHook postInstall
  '';

  meta = {
    homepage = "https://github.com/Xilinx/bootgen";
    description = "Xilinx bootgen tool for generating boot-images for Zynq, ZynqMP and Versal SoC";
    license = lib.licenses.asl20;
    mainProgram = "bootgen";
  };
})
