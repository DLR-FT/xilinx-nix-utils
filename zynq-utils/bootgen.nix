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

  buildInputs = [
    openssl
  ];

  makeFlags = [
    "CROSS_COMPILE=${stdenv.cc.targetPrefix}"
  ];

  installPhase = ''
    mkdir $out

    mkdir $out/bin
    cp bootgen $out/bin
  '';

  meta = {
    homepage = "https://github.com/Xilinx/bootgen";
    description = "Xilinx bootgen tool for generating boot-images for Zynq, ZynqMP and Versal SoC";
    license = lib.licenses.asl20;
    mainProgram = "bootgen";
  };
}
