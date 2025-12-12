{
  lib,
  openssl,
  stdenv,
  zynq-srcs,
}:
stdenv.mkDerivation rec {
  name = "bootgen";
  version = src.rev;

  src = zynq-srcs.bootgen-src;

  patches = [ ../patches/bootgen-pr42.patch ];

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
}
