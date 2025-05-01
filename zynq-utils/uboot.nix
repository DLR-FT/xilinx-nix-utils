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
  which,
  writeText,
  zynq-srcs,
}:

lib.makeOverridable (
  {
    defconfig,
    deviceTree ? null,
    extDeviceTreeBlob ? null,
    extraConfig ? "",
    extraMakeFlags ? [ ],
    extraPatches ? [ ],
    src ? zynq-srcs.uboot-src,
  }@args:
  let
    extraConfigPath = writeText ".extra-config" extraConfig;
  in
  stdenv.mkDerivation (finalAttrs: rec {
    name = "uboot-${defconfig}";
    version = src.rev;

    inherit src;

    nativeBuildInputs = [
      bison
      dtc
      flex
      gnutls
      libuuid
      openssl
      pkg-config
      swig
      which
      # https://github.com/NixOS/nixpkgs/issues/305858
      (buildPackages.python3.withPackages (
        pyPkgs: with pyPkgs; [
          setuptools
          pyelftools
        ]
      ))
    ];

    depsBuildBuild = [ buildPackages.stdenv.cc ];

    env = {
      KBUILD_OUTPUT = "build";
    };

    makeFlags =
      [
        "CROSS_COMPILE=${stdenv.cc.targetPrefix}"
      ]
      ++ lib.lists.optional (deviceTree != null) "DEVICE_TREE=${deviceTree}"
      ++ lib.lists.optional (extDeviceTreeBlob != null) "EXT_DTB=${extDeviceTreeBlob}"
      ++ extraMakeFlags;

    patches = [ ] ++ extraPatches;

    postPatch = ''
      patchShebangs ./scripts
      patchShebangs ./tools

      sed -i 's/\/bin\/pwd/pwd/' ./Makefile
    '';

    configurePhase = ''
      runHook preConfigure

      make ${defconfig}
      cat ${extraConfigPath} >> $KBUILD_OUTPUT/.config

      runHook postConfigure
    '';

    buildPhase = ''
      runHook preBuild

      make ${(lib.strings.escapeShellArgs makeFlags)} -j $NIX_BUILD_CORES

      runHook postBuild
    '';

    installPhase = ''
      runHook preInstall

      mkdir $out
      cp -r ./$KBUILD_OUTPUT/. $out/

      mkdir $out/bin
      cp ./$KBUILD_OUTPUT/tools/mkimage $out/bin/

      runHook postInstall
    '';

    dontFixup = true;

    passthru = {
      inherit args;
      elf = "${finalAttrs.finalPackage.out}/u-boot";
      dtb = "${finalAttrs.finalPackage.out}/u-boot.dtb";
      config = "${finalAttrs.finalPackage.out}/.config";
    };
  })
)
