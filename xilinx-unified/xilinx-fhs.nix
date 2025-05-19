{ buildFHSEnv }:

{
  name ? "xilinx-fhs",
  runScript ? "bash",
  profile ? "",
}:

# Inspired by: https://github.com/nix-community/nix-environments
buildFHSEnv {
  inherit name runScript profile;
  targetPkgs =
    pkgs:
    with pkgs;
    let
      ncurses' = ncurses5.overrideAttrs (old: {
        configureFlags = old.configureFlags ++ [ "--with-termlib" ];
        postFixup = "";
      });
    in
    [
      # runtime deps
      bash
      coreutils
      dbus
      gnumake
      procps
      which

      # libraries
      lsb-release
      ncurses'
      (ncurses'.override { unicodeSupport = false; })
      stdenv.cc.cc
      zlib
      libyaml

      # gui libraries
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
      xorg.xorgserver
      xorg.xlsclients
      libxcrypt-legacy # required for Vivado
      python3
      (libidn.overrideAttrs (_old: {
        # we need libidn.so.11 but nixpkgs has libidn.so.12
        src = fetchurl {
          url = "mirror://gnu/libidn/libidn-1.34.tar.gz";
          sha256 = "sha256-Nxnil18vsoYF3zR5w4CvLPSrTpGeFQZSfkx2cK//bjw=";
        };
      }))

      # compiler stuff to compile some xilinx examples
      ocl-icd
      opencl-clhpp
      opencl-headers

      # misc for installLibs.sh
      (lib.hiPrio gcc)
      graphviz
      nettools
      unzip
    ];
  multiPkgs = null;
}
