{
  dtc,
  lib,
  stdenv,
  xilinx-unified,
  xlsclients,
  zynq-utils,
}:

lib.makeOverridable (
  {
    hwplat,
    extraDts ? [ ],
    extraPatches ? [ ],
    src ? zynq-utils.dt-src,
  }@args:
  let
    baseName = hwplat.baseName;

    genSdtTcl = ''
      hsi open_hw_design ./hwplat/${hwplat.baseName}.xsa
      hsi set_repo_path ./device-tree-xlnx

      hsi create_sw_design device-tree -os device_tree -proc psu_cortexa53_0
      hsi generate_target -dir ./build/dt
      hsi close_hw_design [hsi current_hw_design]

      sdtgen set_dt_param -xsa ./hwplat/${hwplat.baseName}.xsa -dir ./build/sys
      sdtgen generate_sdt
    '';
  in
  stdenv.mkDerivation (finalAttrs: {
    name = "${hwplat.baseName}-sdt";
    version = src.rev;

    srcs = [
      hwplat
      src
    ] ++ extraDts;

    nativeBuildInputs = [
      dtc
      xilinx-unified
      xlsclients
    ];

    unpackPhase = ''
      runHook preUnpack

      cp -r -- ${hwplat} ./hwplat
      cp -r -- ${src} ./device-tree-xlnx

      mkdir ./extra-dts/
      for dts in ${lib.strings.concatStringsSep " " extraDts}; do
        cp -- $dts ./extra-dts/
      done

      chmod -R u=rwX ./hwplat

      runHook postUnpack
    '';

    patches = [ ] ++ extraPatches;

    configurePhase = ''
      runHook preConfigure

      mkdir ./build

      xsct -eval ${lib.strings.escapeShellArg genSdtTcl}

      echo -e "\n" >> ./build/dt/system-top.dts
      for f in ./extra-dts/*.dts; do
        [ -f $f ] || continue

        echo -e "/* $f */" >> ./build/dt/system-top.dts
        cat $f >> ./build/dt/system-top.dts
        echo -e "\n" >> ./build/dt/system-top.dts
      done

      runHook postConfigure
    '';

    buildPhase = ''
      runHook preBuild

      gcc -E -nostdinc -undef -D__DTS__ -x assembler-with-cpp -o ./build/dt/system-top.dts.pp ./build/dt/system-top.dts
      dtc -I dts -O dtb -o ./build/dt/system-top.dtb ./build/dt/system-top.dts.pp

      runHook postBuild
    '';

    installPhase = ''
      runHook preInstall

      mkdir $out
      cp -r -- ./build/dt $out/dt
      cp -r -- ./build/sys $out/sys

      runHook postInstall
    '';

    dontFixup = true;

    passthru = {
      inherit args baseName;
      dts = "${finalAttrs.finalPackage.out}/dt/system-top.dts";
      dtb = "${finalAttrs.finalPackage.out}/dt/system-top.dtb";
      sys.dts = "${finalAttrs.finalPackage.out}/sys/system-top.dts";
    };
  })
)
