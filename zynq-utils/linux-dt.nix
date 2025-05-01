{
  buildPackages,
  dtc,
  lib,
  stdenv,
  zynq-utils,
}:

lib.makeOverridable (
  {
    sdt,
    proc,
    extraPatches ? [ ],
    src ? zynq-utils.lopper-src,
  }@args:
  let
    baseName = sdt.baseName;
  in
  stdenv.mkDerivation (finalAttrs: {
    name = "${baseName}-linux-dt";
    version = src.rev;

    inherit src;

    nativeBuildInputs = [
      dtc

      (lib.lowPrio (
        buildPackages.python3.withPackages (pyPkgs: [
          pyPkgs.setuptools
          (pyPkgs.callPackage ./python-lopper.nix { })
        ])
      ))
    ];

    preUnpack = ''
      cp -r -- ${sdt} ./sdt
      chmod -R a+rwX ./sdt
    '';

    patches = [ ] ++ extraPatches;

    env = {
      LOPPER_DTC_FLAGS = "-@";
    };

    configurePhase = ''
      runHook preConfigure

      mkdir ../linux-dt
      lopper -f --enhanced ../sdt/system-top.dts ../linux-dt/system.dts -- gen_domain_dts ${proc} linux_dt

      runHook postConfigure
    '';

    buildPhase = ''
      runHook preBuild

      dtc -I dts -O dtb -o ../linux-dt/system.dtb ../linux-dt/system.dts

      runHook postBuild
    '';

    installPhase = ''
      runHook preInstall

      mkdir $out
      cp -r -- ../linux-dt/. $out/

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
