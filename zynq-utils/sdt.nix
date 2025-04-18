{
  lib,
  stdenv,
  fetchFromGitHub,
  xilinx-unified,
  dtc,
  xlsclients,
}:

{
  prjName,

  hwplat,
  dt-overlays ? null,
  dt-src ? (
    fetchFromGitHub {
      owner = "Xilinx";
      repo = "device-tree-xlnx";
      rev = "xilinx_v2024.1";
      hash = "sha256-dja+JwbXwiBRJwg/6GNOdONp/vrihmfPBnpjEA/xxnk=";
    }
  ),
  ...
}:
let
  genSdtTcl = ''
    hsi open_hw_design ./hw/${prjName}.xsa
    hsi set_repo_path ./device-tree-xlnx

    hsi create_sw_design device-tree -os device_tree -proc psu_cortexa53_0
    hsi generate_target -dir ./build/dt
    hsi close_hw_design [hsi current_hw_design]

    sdtgen set_dt_param -xsa ./hw/${prjName}.xsa -dir ./build/sdt
    sdtgen generate_sdt
  '';
in
stdenv.mkDerivation (finalAttrs: {
  name = "${prjName}-sdt";
  srcs = [
    hwplat
    dt-overlays
    dt-src
  ];

  nativeBuildInputs = [
    xilinx-unified
    dtc
    xlsclients
  ];

  unpackPhase = ''
    cp -r -- ${hwplat} ./hw
    cp -r -- ${dt-src} ./device-tree-xlnx

    ${
      if !(builtins.isNull dt-overlays) then
        "cp -r -- ${dt-overlays} ./dt-overlays"
      else
        "mkdir ./dt-overlays"
    }

    chmod -R u=rwX ./hw
  '';

  dontPatch = true;

  configurePhase = ''
    mkdir ./build

    xsct -eval ${lib.strings.escapeShellArg genSdtTcl}

    echo -e "\n" >> ./build/dt/system-top.dts
    for f in ./dt-overlays/*.dts; do
      [ -f $f ] || continue

      cat $f >> ./build/dt/system-top.dts
      echo -e "\n" >> ./build/dt/system-top.dts
    done
  '';

  buildPhase = ''
    gcc -E -nostdinc -undef -D__DTS__ -x assembler-with-cpp -o ./build/dt/system-top.dts.pp ./build/dt/system-top.dts
    dtc -I dts -O dtb -o ./build/dt/system-top.dtb ./build/dt/system-top.dts.pp
  '';

  doCheck = false;
  installPhase = ''
    mkdir $out

    cp -r -- ./build/dt $out/dt
    cp -r -- ./build/sdt $out/sdt
  '';

  dontFixup = true;
  dontPatchELF = true;
  dontPatchShebangs = true;
  doInstallCheck = false;
  doDist = false;

  passthru = {
    dtb = "${finalAttrs.finalPackage.out}/dt/system-top.dtb";
  };
})
