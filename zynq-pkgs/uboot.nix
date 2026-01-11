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

  name ? null,
  version ? null,
  src ? zynq-srcs.uboot-src,

  defconfig,
  bl31 ? null,
  tee ? null,
  deviceTree ? null,
  extraConfig ? "",
  extraMakeFlags ? [ ],
  extraPatches ? [ ],
}:

let
  _name = name;
  _version = version;
  extraConfigPath = writeText ".extra-config" extraConfig;
in
stdenv.mkDerivation (finalAttrs: rec {
  name = if _name != null then _name else "zynq-uboot";
  version =
    if _version != null then
      _version
    else if (finalAttrs.src ? rev) then
      finalAttrs.src.rev
    else
      "";

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
    let
      deviceTreeFlag =
        if (deviceTree == null) then
          null
        else if (lib.strings.hasSuffix ".dtb" deviceTree) then # TODO: Can we do better?
          "EXT_DTB=${deviceTree}"
        else
          "DEVICE_TREE=${deviceTree}";
    in
    [
      "CROSS_COMPILE=${stdenv.cc.targetPrefix}"
    ]
    ++ lib.lists.optional (deviceTreeFlag != null) deviceTreeFlag
    ++ lib.lists.optional (bl31 != null) "BL31=${bl31}"
    ++ lib.lists.optional (tee != null) "TEE=${tee}"
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
    elf = "${finalAttrs.finalPackage.out}/u-boot";
    dtb = "${finalAttrs.finalPackage.out}/u-boot.dtb";
    config = "${finalAttrs.finalPackage.out}/.config";
  };
})
