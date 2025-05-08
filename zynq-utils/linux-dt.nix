{
  dtc,
  lib,
  stdenv,
  xilinx-unified,
  zynq-srcs,
}:

lib.makeOverridable (
  {
    hwplat,
    proc,
    extraDtsi ? null,
    extraPatches ? [ ],
    src ? zynq-srcs.dt-src,
  }@args:
  let
    baseName = hwplat.baseName;

    genSdt = ''
      hsi open_hw_design ../hwplat/${baseName}.xsa
      hsi set_repo_path ./.

      hsi create_sw_design device-tree -os device_tree -proc ${proc}
      hsi generate_target -dir ../linux-dt/
      hsi close_hw_design [hsi current_hw_design]
    '';
  in
  stdenv.mkDerivation (finalAttrs: {
    name = "${baseName}-linux-dt";
    version = src.rev;

    inherit src;

    nativeBuildInputs = [
      dtc
      (lib.lowPrio xilinx-unified)
    ];

    patches = [ ] ++ extraPatches;

    postUnpack = ''
      mkdir ./hwplat
      cp -- ${hwplat.xsa} ./hwplat/${baseName}.xsa
    '';

    configurePhase = ''
      runHook preConfigure

      mkdir ../linux-dt
      xsct -eval ${lib.strings.escapeShellArg genSdt}

      ${lib.strings.optionalString (extraDtsi != null) ''
        cp -- ${extraDtsi} ../linux-dt/${builtins.baseNameOf extraDtsi}
        echo -e "#include \"${builtins.baseNameOf extraDtsi}\"" >> ../linux-dt/system-top.dts
      ''}

      runHook postConfigure
    '';

    buildPhase = ''
      runHook preBuild

      gcc -E -nostdinc -undef -D__DTS__ -x assembler-with-cpp -I ../linux-dt/include -o ../linux-dt/system-top.dts.pp ../linux-dt/system-top.dts
      dtc -I dts -O dtb -o ../linux-dt/system-top.dtb ../linux-dt/system-top.dts.pp

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
      dts = "${finalAttrs.finalPackage.out}/system-top.dts";
      dtb = "${finalAttrs.finalPackage.out}/system-top.dtb";
    };
  })
)

# SDT workflow - generate linux dt from sdt instead of hwplat xsa
# does not work for Kria, somehow
# {
#   buildPackages,
#   dtc,
#   lib,
#   stdenv,
#   zynq-srcs,
# }:

# lib.makeOverridable (
#   {
#     sdt,
#     proc,
#     extraPatches ? [ ],
#     src ? zynq-srcs.lopper-src,
#   }@args:
#   let
#     baseName = sdt.baseName;
#   in
#   stdenv.mkDerivation (finalAttrs: {
#     name = "${baseName}-linux-dt";
#     version = src.rev;

#     inherit src;

#     nativeBuildInputs = [
#       dtc

#       (lib.lowPrio (
#         buildPackages.python3.withPackages (pyPkgs: [
#           pyPkgs.setuptools
#           (pyPkgs.callPackage ./python-lopper.nix { })
#         ])
#       ))
#     ];

#     preUnpack = ''
#       cp -r -- ${sdt} ./sdt
#       chmod -R a+rwX ./sdt
#     '';

#     patches = [ ] ++ extraPatches;

#     env = {
#       LOPPER_DTC_FLAGS = "-@";
#     };

#     configurePhase = ''
#       runHook preConfigure

#       lopper -f -i ./lopper/lops/lop-cpulist.dts ../sdt/system-top.dts

#       mkdir ../linux-dt
#       lopper -f --enhanced -i ./lopper/lops/lop-a53-imux.dts ../sdt/system-top.dts ../linux-dt/system.dts -- gen_domain_dts ${proc} linux_dt

#       runHook postConfigure
#     '';

#     buildPhase = ''
#       runHook preBuild

#       dtc -I dts -O dtb -o ../linux-dt/system.dtb ../linux-dt/system.dts

#       runHook postBuild
#     '';

#     installPhase = ''
#       runHook preInstall

#       mkdir $out
#       cp -r -- ../linux-dt/. $out/

#       runHook postInstall
#     '';

#     dontFixup = true;

#     passthru = {
#       inherit args baseName;
#       dts = "${finalAttrs.finalPackage.out}/system.dts";
#       dtb = "${finalAttrs.finalPackage.out}/system.dtb";
#     };
#   })
# )
