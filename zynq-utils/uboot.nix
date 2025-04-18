{
  bison,
  buildPackages,
  dtc,
  flex,
  gnutls,
  lib,
  libuuid,
  openssl,
  pkg-config,
  stdenv,
  swig,
  writeText,
  zynq-utils,
}:
{
  defconfig ? "xilinx_zynqmp_virt_defconfig",
  deviceTree ? "zynqmp-zcu102-rev1.0",
  extDeviceTreeBlob ? null,
  extraConfig ? "",
  bootToEL2 ? false,
  ubootSrc ? zynq-utils.uboot-src,
}:
let
  extra-config-file = writeText ".extra-config" extraConfig;
in
stdenv.mkDerivation (finalAttrs: {
  name = "uboot-${defconfig}";

  srcs = ubootSrc;

  nativeBuildInputs = [
    bison
    dtc
    flex
    gnutls
    libuuid
    openssl
    pkg-config
    swig
    # https://github.com/NixOS/nixpkgs/issues/305858
    (buildPackages.python3.withPackages (
      pyPkgs: with pyPkgs; [
        setuptools
        pyelftools
      ]
    ))
  ];

  depsBuildBuild = [ buildPackages.stdenv.cc ];

  patchPhase =
    ''
      patchShebangs ./scripts
      patchShebangs ./tools

      sed -i 's/\/bin\/pwd/pwd/' ./Makefile
    ''
    + lib.strings.optionalString bootToEL2 ''
      substituteInPlace ./board/xilinx/zynqmp/zynqmp.c \
        --replace armv8_switch_to_el1 armv8_switch_to_el2
    '';

  configurePhase = ''
    export KBUILD_OUTPUT=build
    export CROSS_COMPILE=${stdenv.cc.targetPrefix}

    make ${defconfig}

    cat ${extra-config-file} >> $KBUILD_OUTPUT/.config
  '';

  buildPhase = ''
    ${lib.strings.optionalString (deviceTree != null) ''
      export DEVICE_TREE=${deviceTree}
    ''}

    ${lib.strings.optionalString (extDeviceTreeBlob != null) ''
      export EXT_DTB=${extDeviceTreeBlob}
    ''}

    make -j $NIX_BUILD_CORES
  '';

  installPhase = ''
    mkdir $out
    cp -r ./build/. $out/

    mkdir $out/bin
    cp ./build/tools/mkimage $out/bin/
  '';

  dontFixup = true;

  passthru = {
    elf = "${finalAttrs.finalPackage.out}/u-boot.elf";
    dtb = "${finalAttrs.finalPackage.out}/u-boot.dtb";
    config = "${finalAttrs.finalPackage.out}/.config";
  };
})
