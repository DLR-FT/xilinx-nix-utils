{ buildFHSEnv }:

{
  name ? "xilinx-fhs",
  runScript ? "bash",
  profile ? "",
  extraBwrapArgs ? [ ],
}:

# Inspired by: https://github.com/nix-community/nix-environments
buildFHSEnv {
  inherit
    name
    runScript
    profile
    extraBwrapArgs
    ;
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
      fuse
      gnumake
      procps
      ratarmount
      util-linux
      which

      # libraries
      libtinfo
      libusb1
      libyaml
      lsb-release
      ncurses'
      stdenv.cc.cc
      zlib
      (ncurses'.override { unicodeSupport = false; })

      # gui libraries
      fontconfig
      freetype
      glib
      gtk2
      gtk3
      libxcrypt-legacy # required for Vivado
      python3
      xorg.libX11
      xorg.libXext
      xorg.libXft
      xorg.libXi
      xorg.libXrender
      xorg.libXtst
      xorg.libxcb
      xorg.xlsclients
      xorg.xorgserver
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
      graphviz
      nettools
      unzip
      (lib.hiPrio gcc)
    ];
  multiPkgs = null;
}
