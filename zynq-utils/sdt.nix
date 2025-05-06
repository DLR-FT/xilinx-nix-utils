{
  dtc,
  lib,
  stdenv,
  xilinx-unified,
  xlsclients,
  zynq-srcs,
}:

lib.makeOverridable (
  {
    hwplat,
    boardDts ? null,
    extraDtsi ? null,
    extraPatches ? [ ],
    src ? zynq-srcs.sdt-src,
  }@args:
  let
    baseName = hwplat.baseName;

    sdtTcl = ''
      sdtgen set_dt_param \
        -xsa ${hwplat.xsa} \
        ${lib.strings.optionalString (boardDts != null) "-board_dts ${boardDts}"} \
        ${
          lib.strings.optionalString (
            extraDtsi != null
          ) "-include_dts ../extra-dtsi/${builtins.baseNameOf extraDtsi}"
        } \
        -dir ./build
      sdtgen generate_sdt
    '';
  in
  stdenv.mkDerivation (finalAttrs: {
    name = "${baseName}-sdt";
    version = src.rev;

    inherit src;

    nativeBuildInputs = [
      dtc
      xlsclients
      (lib.lowPrio xilinx-unified)
    ];

    patches = [ ] ++ extraPatches;

    env = {
      CUSTOM_SDT_REPO = src;
    };

    postUnpack = ''
      mkdir ./extra-dtsi

      ${lib.strings.optionalString (extraDtsi != null) ''
        cp -r -- ${extraDtsi} ./extra-dtsi/${builtins.baseNameOf extraDtsi}
      ''}
    '';

    buildPhase = ''
      runHook preBuild

      xsct <(echo ${lib.escapeShellArg sdtTcl})

      gcc -E -nostdinc -undef -D__DTS__ -x assembler-with-cpp -o ./build/system-top.dts.pp ./build/system-top.dts
      dtc -I dts -O dtb -o ./build/system-top.dtb ./build/system-top.dts.pp

      runHook postBuild
    '';

    installPhase = ''
      runHook preInstall

      mkdir $out
      cp -r -- ./build/. $out/

      runHook postInstall
    '';

    dontFixup = true;

    passthru = {
      inherit args baseName;
      dts = "${finalAttrs.finalPackage.out}/system-top.dts";
      dtb = "${finalAttrs.finalPackage.out}/system-top.dtb";
    };
  })
)
