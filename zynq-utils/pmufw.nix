{
  buildPackages,
  cmake,
  lib,
  libclang,
  ninja,
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
    name = "${sdt.baseName}-pmufw";
    version = src.rev;

    inherit src;

    nativeBuildInputs = [
      cmake
      libclang
      ninja
      (buildPackages.python3.withPackages (pyPkgs: [
        pyPkgs.setuptools
        (pyPkgs.callPackage ./python-lopper.nix { })
      ]))

      (buildPackages.writeShellScriptBin "mb-addr2line" "microblazeel-none-elf-addr2line $@")
      (buildPackages.writeShellScriptBin "mb-ar" "microblazeel-none-elf-ar $@")
      (buildPackages.writeShellScriptBin "mb-as" "microblazeel-none-elf-as $@")
      (buildPackages.writeShellScriptBin "mb-c++" "microblazeel-none-elf-c++ $@")
      (buildPackages.writeShellScriptBin "mb-cc" "microblazeel-none-elf-cc $@")
      (buildPackages.writeShellScriptBin "mb-c++filt" "microblazeel-none-elf-c++filt $@")
      (buildPackages.writeShellScriptBin "mb-cpp" "microblazeel-none-elf-cpp $@")
      (buildPackages.writeShellScriptBin "mb-elfedit" "microblazeel-none-elf-elfedit $@")
      (buildPackages.writeShellScriptBin "mb-g++" "microblazeel-none-elf-g++ $@")
      (buildPackages.writeShellScriptBin "mb-gcc" "microblazeel-none-elf-gcc $@")
      (buildPackages.writeShellScriptBin "mb-ld" "microblazeel-none-elf-ld $@")
      (buildPackages.writeShellScriptBin "mb-ld.bfd" "microblazeel-none-elf-ld.bfd $@")
      (buildPackages.writeShellScriptBin "mb-nm" "microblazeel-none-elf-nm $@")
      (buildPackages.writeShellScriptBin "mb-objcopy" "microblazeel-none-elf-objcopy $@")
      (buildPackages.writeShellScriptBin "mb-objdump" "microblazeel-none-elf-objdump $@")
      (buildPackages.writeShellScriptBin "mb-ranlib" "microblazeel-none-elf-ranlib $@")
      (buildPackages.writeShellScriptBin "mb-readelf" "microblazeel-none-elf-readelf $@")
      (buildPackages.writeShellScriptBin "mb-size" "microblazeel-none-elf-size $@")
      (buildPackages.writeShellScriptBin "mb-strings" "microblazeel-none-elf-strings $@")
      (buildPackages.writeShellScriptBin "mb-strip" "microblazeel-none-elf-strip $@")
    ];

    patches = [ ] ++ extraPatches;

    configurePhase = ''
      runHook preConfigure

      export LOPPER_DTC_FLAGS="-@";
      export ESW_REPO=$(realpath .)

      mkdir ./pmufw-bsp
      pushd ./pmufw-bsp
      python $ESW_REPO/scripts/pyesw/create_bsp.py -t zynqmp_pmufw -s ${sdt.dts} -p psu_pmu_0
      popd

      mkdir ./pmufw
      pushd ./pmufw
      python $ESW_REPO/scripts/pyesw/create_app.py -t zynqmp_pmufw -d ../pmufw-bsp
      popd

      runHook postConfigure
    '';

    buildPhase = ''
      runHook preBuild

      export LOPPER_DTC_FLAGS="-@";
      export ESW_REPO=$(realpath .)

      python $ESW_REPO/scripts/pyesw/build_app.py --ws_dir ./pmufw --build_dir ./pmufw/build

      runHook postBuild
    '';

    installPhase = ''
      runHook preInstall

      cp -r -- ./pmufw/build $out

      runHook postInstall
    '';

    dontFixup = true;

    passthru = {
      inherit args baseName;
      elf = "${finalAttrs.finalPackage.out}/zynqmp_pmufw.elf";
    };
  })
)
