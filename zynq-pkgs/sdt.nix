{
  dtc,
  lib,
  stdenv,
  xilinx-unified,
  xlsclients,
  zynq-srcs,

  name ? null,
  version ? null,
  src ? zynq-srcs.sdt-src,

  xsa,
  boardDts ? null,
  extraDtsi ? null,
  extraPatches ? [ ],
}@args:

let
  sdtTcl = ''
    sdtgen set_dt_param \
      -xsa ${xsa} \
      ${lib.strings.optionalString (boardDts != null) "-board_dts ${boardDts}"} \
      ${
        lib.strings.optionalString (
          extraDtsi != null
        ) "-user_dts ../extra-dtsi/${builtins.baseNameOf extraDtsi}"
      } \
      -dir ./build
    sdtgen generate_sdt
  '';
in
stdenv.mkDerivation (finalAttrs: {
  name = if args.name != null then args.name else "zynq-sdt";
  version =
    if args.version != null then
      args.version
    else if (finalAttrs.src ? rev) then
      finalAttrs.src.rev
    else
      "unstable";

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
    dts = "${finalAttrs.finalPackage.out}/system-top.dts";
    dtb = "${finalAttrs.finalPackage.out}/system-top.dtb";
  };
})
