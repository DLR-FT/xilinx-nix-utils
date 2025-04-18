{
  dtc,
  stdenv,
  zynq-utils,
}:
{
  plat ? "zynqmp",
  tfa-src ? zynq-utils.tfa-src,
}:
stdenv.mkDerivation (finalAttrs: {
  name = "trusted-firmware-a-${plat}";

  src = tfa-src;

  nativeBuildInputs = [
    dtc
  ];

  dontPatch = true;
  dontConfigure = true;

  buildPhase = ''
    make -j $NIX_BUILD_CORES \
      CROSS_COMPILE=${stdenv.cc.targetPrefix} \
      PLAT=${plat} \
      bl31
  '';

  installPhase = ''
    mkdir $out
    cp -r ./build/. $out/
  '';

  dontFixup = true;

  passthru = {
    elf = "${finalAttrs.finalPackage.out}/${plat}/release/bl31/bl31.elf";
  };
})
