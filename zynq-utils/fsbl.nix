{
  buildPackages,
  cmake,
  lib,
  libclang,
  stdenv,
  zynq-utils,
}:

lib.makeOverridable (
  {
    sdt,
    extraPatches ? [ ],
    src ? zynq-utils.embeddedsw-src,
  }@args:
  let
    baseName = sdt.baseName;
  in
  stdenv.mkDerivation (finalAttrs: {
    name = "${baseName}-fsbl";

    inherit src;

    nativeBuildInputs = [
      cmake
      libclang
      (buildPackages.python3.withPackages (pyPkgs: [
        pyPkgs.setuptools
        (pyPkgs.callPackage ./lopper.nix { })
      ]))

      stdenv.cc
      (buildPackages.writeShellScriptBin "aarch64-none-elf-addr2line" "aarch64-unknown-none-elf-addr2line $@")
      (buildPackages.writeShellScriptBin "aarch64-none-elf-ar" "aarch64-unknown-none-elf-ar $@")
      (buildPackages.writeShellScriptBin "aarch64-none-elf-as" "aarch64-unknown-none-elf-as $@")
      (buildPackages.writeShellScriptBin "aarch64-none-elf-c++" "aarch64-unknown-none-elf-c++ $@")
      (buildPackages.writeShellScriptBin "aarch64-none-elf-cc" "aarch64-unknown-none-elf-cc $@")
      (buildPackages.writeShellScriptBin "aarch64-none-elf-c++filt" "aarch64-unknown-none-elf-c++filt $@")
      (buildPackages.writeShellScriptBin "aarch64-none-elf-cpp" "aarch64-unknown-none-elf-cpp $@")
      (buildPackages.writeShellScriptBin "aarch64-none-elf-elfedit" "aarch64-unknown-none-elf-elfedit $@")
      (buildPackages.writeShellScriptBin "aarch64-none-elf-g++" "aarch64-unknown-none-elf-g++ $@")
      (buildPackages.writeShellScriptBin "aarch64-none-elf-gcc" "aarch64-unknown-none-elf-gcc $@")
      (buildPackages.writeShellScriptBin "aarch64-none-elf-gprof" "aarch64-unknown-none-elf-gprof $@")
      (buildPackages.writeShellScriptBin "aarch64-none-elf-ld" "aarch64-unknown-none-elf-ld $@")
      (buildPackages.writeShellScriptBin "aarch64-none-elf-ld.bfd" "aarch64-unknown-none-elf-ld.bfd $@")
      (buildPackages.writeShellScriptBin "aarch64-none-elf-nm" "aarch64-unknown-none-elf-nm $@")
      (buildPackages.writeShellScriptBin "aarch64-none-elf-objcopy" "aarch64-unknown-none-elf-objcopy $@")
      (buildPackages.writeShellScriptBin "aarch64-none-elf-objdump" "aarch64-unknown-none-elf-objdump $@")
      (buildPackages.writeShellScriptBin "aarch64-none-elf-ranlib" "aarch64-unknown-none-elf-ranlib $@")
      (buildPackages.writeShellScriptBin "aarch64-none-elf-readelf" "aarch64-unknown-none-elf-readelf $@")
      (buildPackages.writeShellScriptBin "aarch64-none-elf-size" "aarch64-unknown-none-elf-size $@")
      (buildPackages.writeShellScriptBin "aarch64-none-elf-strings" "aarch64-unknown-none-elf-strings $@")
      (buildPackages.writeShellScriptBin "aarch64-none-elf-strip" "aarch64-unknown-none-elf-strip $@")
    ];

    patches = [ ] ++ extraPatches;

    configurePhase = ''
      runHook preConfigure

      export LOPPER_DTC_FLAGS="-@";
      export ESW_REPO=$(realpath .)

      mkdir ./fsbl-bsp
      pushd ./fsbl-bsp
      python $ESW_REPO/scripts/pyesw/create_bsp.py -t zynqmp_fsbl -s ${sdt.sys.dts} -p psu_cortexa53_0
      popd

      mkdir ./fsbl
      pushd ./fsbl
      python $ESW_REPO/scripts/pyesw/create_app.py -t zynqmp_fsbl -d ../fsbl-bsp
      popd

      runHook postConfigure
    '';

    buildPhase = ''
      runHook preBuild

      export LOPPER_DTC_FLAGS="-@";
      export ESW_REPO=$(realpath .)

      python $ESW_REPO/scripts/pyesw/build_app.py --ws_dir ./fsbl --build_dir ./fsbl/build

      runHook postBuild
    '';

    installPhase = ''
      runHook preInstall

      cp -r -- ./fsbl/build $out

      runHook postInstall
    '';

    dontFixup = true;

    passthru = {
      inherit args baseName;
      elf = "${finalAttrs.finalPackage.out}/zynqmp_fsbl.elf";
    };
  })
)
