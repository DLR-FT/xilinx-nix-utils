{
  buildPackages,
  dtc,
  lib,
  stdenv,
  zynq-srcs,
}:

lib.makeOverridable (
  {
    sdt,
    # Processor id string (ps7_cortexa9_0, psu_cortexa53_0, ...)
    proc,
    # Optional: Extra lop dts files, which can manipulate the generated dts. See github.com/devicetree-org/lopper
    extraLops ? [ ],
    # Optional: Extra external device tree file to include
    extraDtsi ? [ ],
    extraPatches ? [ ],
    src ? zynq-srcs.lopper-src,
  }@args:
  let
    baseName = sdt.baseName;
  in
  stdenv.mkDerivation (finalAttrs: {
    name = "${baseName}-linux-dt";
    version = src.rev;

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
      inherit args baseName;
      dts = "${finalAttrs.finalPackage.out}/system.dts";
      dtb = "${finalAttrs.finalPackage.out}/system.dtb";
    };
  })
)
