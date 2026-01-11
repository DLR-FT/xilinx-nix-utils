{
  buildPackages,
  dtc,
  lib,
  stdenv,
  zynq-srcs,

  name ? null,
  version ? null,
  src ? zynq-srcs.lopper-src,

  sdt,
  proc,
  extraLops ? [ ],
  extraDtsi ? [ ],
  extraPatches ? [ ],
}:

stdenv.mkDerivation (finalAttrs: {
  name = if name != null then name else "zynq-linux-dt";
  version =
    if version != null then
      version
    else if (sdt.src ? rev) then
      sdt.src.rev
    else
      "";

  srcs = [
    src
    sdt
  ];

  nativeBuildInputs = [
    dtc

    (buildPackages.python3.withPackages (pyPkgs: [
      pyPkgs.setuptools
      (pyPkgs.callPackage ./python-lopper.nix { })
    ]))
  ];

  patches = [ ] ++ extraPatches;

  env = {
    LOPPER_DTC_FLAGS = "-@";
  };

  unpackPhase = ''
    runHook preUnpack

    cp -r -- ${src} ./lopper
    chmod -R a+rwX ./lopper

    cp -r -- ${sdt} ./sdt
    chmod -R a+rwX ./sdt

    cd ./lopper

    runHook postUnpack
  '';

  configurePhase = ''
    runHook preConfigure

    mkdir ../linux-dt
    lopper -f --enhanced ${lib.strings.concatMapStringsSep " " (x: "-i ${x}") extraLops} \
      ../sdt/system-top.dts ../linux-dt/system.dts -- gen_domain_dts ${proc} linux_dt

    mkdir ../linux-dt/extra
    ${lib.strings.concatMapStrings (x: ''
      cp -- ${x} ../linux-dt/extra/${builtins.baseNameOf x}
      echo -e "#include \"extra/${builtins.baseNameOf x}\"" >> ../linux-dt/system.dts
    '') extraDtsi}

    runHook postConfigure
  '';

  buildPhase = ''
    runHook preBuild

    gcc -E -nostdinc -I ../sdt/include -undef -D__DTS__ -x assembler-with-cpp -o ../linux-dt/system.dts.pp ../linux-dt/system.dts
    dtc -I dts -O dtb -o ../linux-dt/system.dtb ../linux-dt/system.dts.pp

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    mkdir $out
    cp -r ../linux-dt/. $out/

    runHook postInstall
  '';

  dontFixup = true;

  passthru = {
    dts = "${finalAttrs.finalPackage.out}/system.dts";
    dtb = "${finalAttrs.finalPackage.out}/system.dtb";
  };
})
