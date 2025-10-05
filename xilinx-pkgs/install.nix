{
  buildFHSEnv,
  lib,
  rapidgzip,
  stdenvNoCC,
  writeShellScript,

  # Just generate the default install_config.txt from the installer
  genInstallConfig ? false,
}:
{
  baseName,
  version,
  installTar,
  installConfig,
  agreements ? [
    "3rdPartyEULA"
    "XilinxEULA"
  ],
}:

let
  agreedLicenses = lib.strings.concatStringsSep "," agreements;

  fhs = buildFHSEnv {
    name = "xilinx-installer-fhs";

    # use unshare so that we can use ratarmount to mount the tar archive.
    # otherwise we get a permission error on mount attempt
    runScript = "unshare -m -r bash";

    # /nix/store is mounted read-only in the fhs by default:
    # https://github.com/NixOS/nixpkgs/pull/381032
    # add extra read-write mount for $out, so that we can directly install into the nix store
    extraBwrapArgs = [ "--bind $out $out" ];

    targetPkgs =
      pkgs: with pkgs; [
        fuse3
        ratarmount
        (util-linux.override {
          capabilitiesSupport = false;
          # cryptsetupSupport = false;
          ncursesSupport = false;
          nlsSupport = false;
          pamSupport = false;
          shadowSupport = false;
          systemdSupport = false;
          writeSupport = false;
        })
      ];
  };

  genInstallConfigScript = writeShellScript "xilinx-install" ''
    if [ -e /dev/fuse ]; then
      # Just in case the xilinx installer wants to write into the "extracted" read-only archive
      mkdir tar-write-overlay

      ratarmount --write-overlay ./tar-write-overlay $src ./unpack
    fi

    # Find root extraction dir. We dont know the name. Its the first and only one.
    unpack=$(find ./unpack -mindepth 1 -maxdepth 1 -type d)

    echo -e "1\n1\n" | "$unpack/xsetup" \
      --agree ${lib.strings.escapeShellArg agreedLicenses} \
      --batch ConfigGen

    if [ -e /dev/fuse ]; then
      ratarmount -u ./unpack
    fi
  '';

  installScript = writeShellScript "xilinx-install" ''
    if [ -e /dev/fuse ]; then
      mkdir tar-write-overlay
      ratarmount --write-overlay ./tar-write-overlay $src ./unpack
    fi

    unpack=$(find ./unpack -mindepth 1 -maxdepth 1 -type d)

    $unpack/xsetup \
      --agree ${lib.strings.escapeShellArg agreedLicenses} \
      --batch Install \
      --config ./.Xilinx/install_config.txt

    if [ -e /dev/fuse ]; then
      ratarmount -u ./unpack
    fi
  '';
in
stdenvNoCC.mkDerivation {
  pname = "${baseName}-unwrapped";
  inherit version;

  src = installTar;

  nativeBuildInputs = [
    fhs
    rapidgzip
  ];

  # As an alternative to unpacking the installer archive before running the installer,
  # we can also mount the archive using ratarmount (random-access tar mount) which is pretty much instant for a tar archive,
  # making the extraction lazy and circumventing the detour of extracting to disk and reading from disk.
  #
  # But this only works if we can do a fuse mount in the sandbox which needs the /dev/fuse device.
  # One can use --extra-sandbox-paths /dev/fuse in the cli or in the nix.conf to pass the fuse device into the sandbox.
  # If the /dev/fuse device is available, which it is not by default, we use mounting instead of unpacking.
  unpackPhase = ''
    runHook preUnpack

    if [ -e /dev/fuse ]; then
      echo "Found /dev/fuse. Using mounting (ratarmount) instead of unpacking."
    else
      echo "Unpacking archive. Use \"--extra-sandbox-paths /dev/fuse\" to mount (ratarmount) the archive instead."
      mkdir /build/unpack
      if [[ $src == *.tar.gz ]]; then
        rapidgzip --decompress --stdout "$src" | tar -x -C /build/unpack
      elif [[ $src == *.tar ]]; then
        tar -xf "$src" -C /build/unpack
      fi
    fi

    runHook postUnpack
  '';

  dontPatch = true;
  dontConfigure = true;
  dontBuild = true;

  installPhase = ''
    runHook preInstall

    mkdir .Xilinx
    mkdir $out

    ${
      if genInstallConfig then
        ''
          xilinx-installer-fhs ${genInstallConfigScript}
        ''
      else
        ''
          cp -- ${installConfig} ./.Xilinx/install_config.txt
          chmod a+rw ./.Xilinx/install_config.txt

          substituteInPlace ./.Xilinx/install_config.txt \
            --replace-fail /tools/Xilinx $out

          xilinx-installer-fhs ${installScript}
        ''
    }

    mv .Xilinx $out

    runHook postInstall
  '';

  dontFixup = true;
  dontPatchELF = true;
  dontPatchShebangs = true;
  dontPruneLibtoolFiles = true;
  dontStrip = true;
  noAuditTmpdir = true;

  passthru = {
    inherit baseName fhs;
  };

  meta = {
    description = "AMD/Xilinx toolchain";
    homepage = "https://www.xilinx.com/products/design-tools/vivado.html";
    license = lib.licenses.unfree;
    maintainers = with lib.maintainers; [ wucke13 ];
    platforms = lib.platforms.unix;
  };
}
