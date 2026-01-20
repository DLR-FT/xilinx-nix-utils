{
  buildPackages,
  cmake,
  lib,
  libclang,
  ninja,
  stdenv,
  zynq-srcs,

  name ? null,
  version ? null,
  src ? zynq-srcs.embeddedsw-src,

  sdt,
  plat,
  proc,
  extraPatches ? [ ],
}@args:

let
  template =
    {
      zynq7 = "zynq_fsbl";
      zynqmp = "zynqmp_fsbl";
    }
    .${plat};

  mode = if stdenv.targetPlatform.is32bit then "32-bit" else "64-bit";

  toolchainFile =
    {
      ps7_cortexa9_0 = "cortexa9_toolchain.cmake";
      ps7_cortexa9_1 = "cortexa9_toolchain.cmake";
      psu_cortexa53_0 = "cortexa53_toolchain.cmake";
      psu_cortexa53_1 = "cortexa53_toolchain.cmake";
      psu_cortexa53_2 = "cortexa53_toolchain.cmake";
      psu_cortexa53_3 = "cortexa53_toolchain.cmake";
    }
    .${proc};

in
stdenv.mkDerivation (finalAttrs: {
  name = if args.name != null then args.name else "zynq-fsbl";
  version =
    if args.version != null then
      args.version
    else if (finalAttrs.src ? rev) then
      finalAttrs.src.rev
    else
      "unstable";

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

  env = {
    LOPPER_DTC_FLAGS = "-@";
  };

  hardeningDisable = [ "all" ];

  patches = [ ] ++ extraPatches;

  configurePhase = ''
    runHook preConfigure

    export ESW_REPO=$(realpath .)

    echo "set(CMAKE_C_COMPILER ${stdenv.cc.targetPrefix}gcc)" >> ./cmake/toolchainfiles/${toolchainFile}
    echo "set(CMAKE_CXX_COMPILER ${stdenv.cc.targetPrefix}g++)" >> ./cmake/toolchainfiles/${toolchainFile}
    echo "set(CMAKE_ASM_COMPILER ${stdenv.cc.targetPrefix}gcc)" >> ./cmake/toolchainfiles/${toolchainFile}
    echo "set(CMAKE_AR ${stdenv.cc.targetPrefix}ar)" >> ./cmake/toolchainfiles/${toolchainFile}
    echo "set(CMAKE_SIZE ${stdenv.cc.targetPrefix}size)" >> ./cmake/toolchainfiles/${toolchainFile}

    mkdir ./fsbl-bsp
    pushd ./fsbl-bsp
    python $ESW_REPO/scripts/pyesw/repo.py -st $ESW_REPO
    python $ESW_REPO/scripts/pyesw/create_bsp.py -t ${template} -s ${sdt.dts} -p ${proc} ${lib.strings.optionalString (lib.strings.hasInfix "cortexa53" proc) "-m ${mode}"}
    popd

    mkdir ./fsbl
    pushd ./fsbl
    python $ESW_REPO/scripts/pyesw/repo.py -st $ESW_REPO
    python $ESW_REPO/scripts/pyesw/create_app.py -t ${template} -d ../fsbl-bsp
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
    elf = "${finalAttrs.finalPackage.out}/${template}.elf";
  };
})
