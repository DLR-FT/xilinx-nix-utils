{
  stdenv,
  buildFHSEnv,
  stdenvNoCC,
  makeWrapper,
}:

{
  inputDerivation,
  extraTargetPkgs ? pkgs: [ ],
}:
let
  fhs = buildFHSEnv {
    name = "xilinx-fhs";
    runScript = "";
    targetPkgs =
      pkgs:
      with pkgs;
      let
        ncurses5' = callPackage (import ../nixpkgs/ncurses-patched-25-05.nix) { abiVersion = "5"; };
        ncurses6' = callPackage (import ../nixpkgs/ncurses-patched-25-05.nix) { };
      in
      [
        coreutils
        graphviz
        hostname
        pkg-config
        python3
        unzip
        which

        stdenv.cc.cc.lib
        libusb1
        libxcrypt
        libyaml
        lsb-release
        zlib
        (libtinfo.override { ncurses = ncurses5'; })
        (libtinfo.override { ncurses = ncurses6'; })

        fontconfig
        freetype
        glib
        gtk2
        gtk3
        xorg.libX11
        xorg.libXext
        xorg.libXft
        xorg.libXi
        xorg.libXrender
        xorg.libXtst
        xorg.libxcb
        xorg.xlsclients
        xorg.xorgserver
      ]
      ++ extraTargetPkgs pkgs;
  };
in
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = inputDerivation.args.name + "-wrapped";
  version = inputDerivation.version;

  dontUnpack = true;

  dontPatch = true;

  dontConfigure = true;

  dontBuild = true;

  nativeBuildInputs = [ makeWrapper ];

  installPhase = ''
    mkdir --parent -- "$out/bin"
    while IFS= read -r -d "" dir ; do
      echo $dir
      while IFS= read -r -d "" file ; do
      echo $file
        makeWrapper \
            "${fhs}/bin/xilinx-fhs" \
            "$out/bin/''${file##*/}" \
            --run "$dir/settings64.sh" \
            --set LC_NUMERIC 'en_US.UTF-8' \
            --add-flags "\"$file\""
      done < <(find "$dir" -maxdepth 2 -path '*/bin/*' -type f -executable -print0)
    done < <(find ${inputDerivation}/ -maxdepth 3 -type f -name 'settings64.sh' -printf '%h\0')
  '';

  dontFixup = true;

  passthru = {
    inherit fhs;
    unwrapped = inputDerivation;
  };

  meta = inputDerivation.meta;
})
