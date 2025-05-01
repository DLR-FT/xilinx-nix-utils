{
  buildPackages,
  cmake,
  lib,
  libclang,
  ninja,
  stdenv,
  zynq-srcs,
}:

lib.makeOverridable (
  {
    sdt,
    extraPatches ? [ ],
    src ? zynq-srcs.embeddedsw-src,
  }@args:
  let
    baseName = sdt.baseName;
  in
  stdenv.mkDerivation (finalAttrs: {
    name = "${baseName}-fsbl";
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

      echo "set(CMAKE_C_COMPILER ${stdenv.cc.targetPrefix}gcc)" >> ./cmake/toolchainfiles/cortexa53_toolchain.cmake
      echo "set(CMAKE_CXX_COMPILER ${stdenv.cc.targetPrefix}g++)" >> ./cmake/toolchainfiles/cortexa53_toolchain.cmake
      echo "set(CMAKE_ASM_COMPILER ${stdenv.cc.targetPrefix}gcc)" >> ./cmake/toolchainfiles/cortexa53_toolchain.cmake
      echo "set(CMAKE_AR ${stdenv.cc.targetPrefix}ar)" >> ./cmake/toolchainfiles/cortexa53_toolchain.cmake
      echo "set(CMAKE_SIZE ${stdenv.cc.targetPrefix}size)" >> ./cmake/toolchainfiles/cortexa53_toolchain.cmake

      mkdir ./fsbl-bsp
      pushd ./fsbl-bsp
      python $ESW_REPO/scripts/pyesw/create_bsp.py -t zynqmp_fsbl -s ${sdt.dts} -p psu_cortexa53_0
      popd

      mkdir ./fsbl
      pushd ./fsbl
      python $ESW_REPO/scripts/pyesw/create_app.py -t zynqmp_fsbl -d ../fsbl-bsp
      popd

      runHook postConfigure
    '';

    buildPhase = ''
      runHook preBuild

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
