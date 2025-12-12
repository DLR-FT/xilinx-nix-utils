{
  buildPackages,
  cmake-compat35,
  lib,
  libclang,
  ninja,
  stdenv,
  zynq-srcs,
}:

lib.makeOverridable (
  {
    sdt,
    # Platform string (zynq7, zynqmp)
    plat,
    # Processor id string (ps7_cortexa9_0, psu_cortexa53_0, ...)
    proc,
    extraPatches ? [ ],
    src ? zynq-srcs.embeddedsw-src,
  }@args:
  let
    baseName = sdt.baseName;

    template =
      {
        zynqmp = "zynqmp_pmufw";
      }
      .${plat};

    mode = if stdenv.targetPlatform.is32bit then "32-bit" else "64-bit";

    toolchainFile =
      {
        psu_pmu_0 = "microblaze-pmu_toolchain.cmake";
      }
      .${proc};
  in
  stdenv.mkDerivation (finalAttrs: {
    name = "${sdt.baseName}-pmufw";
    version = src.rev;

    inherit src;

    nativeBuildInputs = [
      cmake-compat35
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

      echo "set(CMAKE_C_COMPILER ${stdenv.cc.targetPrefix}gcc)" >> ./cmake/toolchainfiles/${toolchainFile}
      echo "set(CMAKE_CXX_COMPILER ${stdenv.cc.targetPrefix}g++)" >> ./cmake/toolchainfiles/${toolchainFile}
      echo "set(CMAKE_ASM_COMPILER ${stdenv.cc.targetPrefix}gcc)" >> ./cmake/toolchainfiles/${toolchainFile}
      echo "set(CMAKE_AR ${stdenv.cc.targetPrefix}ar)" >> ./cmake/toolchainfiles/${toolchainFile}
      echo "set(CMAKE_SIZE ${stdenv.cc.targetPrefix}size)" >> ./cmake/toolchainfiles/${toolchainFile}

      mkdir ./pmufw-bsp
      pushd ./pmufw-bsp
      python $ESW_REPO/scripts/pyesw/repo.py -st $ESW_REPO
      python $ESW_REPO/scripts/pyesw/create_bsp.py -t ${template} -s ${sdt.dts} -p ${proc} ${lib.strings.optionalString (lib.strings.hasInfix "cortexa53" proc) "-m ${mode}"}
      popd

      mkdir ./pmufw
      pushd ./pmufw
      python $ESW_REPO/scripts/pyesw/repo.py -st $ESW_REPO
      python $ESW_REPO/scripts/pyesw/create_app.py -t ${template} -d ../pmufw-bsp
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
      elf = "${finalAttrs.finalPackage.out}/${template}.elf";
    };
  })
)
