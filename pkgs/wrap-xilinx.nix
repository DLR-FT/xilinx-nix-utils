{ stdenvNoCC, makeWrapper, genXilinxFhs, inputDerivation }:

stdenvNoCC.mkDerivation (finalAttrs: {
  pname = inputDerivation.pname + "-wrapped";
  version = inputDerivation.version;

  dontUnpack = true;
  nativeBuildInputs = [ makeWrapper ];
  installPhase = ''
    mkdir --parent -- "$out/bin"
    while IFS= read -r -d "" dir ; do
      echo $dir
      while IFS= read -r -d "" file ; do
      echo $file
        makeWrapper \
            "${genXilinxFhs { runScript = ""; }}/bin/xilinx-fhs" \
            "$out/bin/''${file##*/}" \
            --run "$dir/settings64.sh" \
            --set LC_NUMERIC 'en_US.UTF-8' \
            --add-flags "\"$file\""
      done < <(find "$dir" -maxdepth 2 -path '*/bin/*' -type f -executable -print0)
    done < <(find ${inputDerivation}/ -maxdepth 3 -type f -name 'settings64.sh' -printf '%h\0')
  '';
})
