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
    ];

    patches = [ ] ++ extraPatches;

    env = {
      LOPPER_DTC_FLAGS = "-@";
    };

    configurePhase = ''
      runHook preConfigure

      export ESW_REPO=$(realpath .)

      echo "set(CMAKE_C_COMPILER ${stdenv.cc.targetPrefix}gcc)" >> ./cmake/toolchainfiles/microblaze-pmu_toolchain.cmake
      echo "set(CMAKE_CXX_COMPILER ${stdenv.cc.targetPrefix}g++)" >> ./cmake/toolchainfiles/microblaze-pmu_toolchain.cmake
      echo "set(CMAKE_ASM_COMPILER ${stdenv.cc.targetPrefix}gcc)" >> ./cmake/toolchainfiles/microblaze-pmu_toolchain.cmake
      echo "set(CMAKE_AR ${stdenv.cc.targetPrefix}ar)" >> ./cmake/toolchainfiles/microblaze-pmu_toolchain.cmake
      echo "set(CMAKE_SIZE ${stdenv.cc.targetPrefix}size)" >> ./cmake/toolchainfiles/microblaze-pmu_toolchain.cmake

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
