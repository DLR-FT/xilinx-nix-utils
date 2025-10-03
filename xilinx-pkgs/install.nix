{
  lib,
  stdenv,
  util-linux,
  rapidgzip,
  genXilinxFhs,
  writeShellScript,
  genInstallConfig ? false,
}:

{
  name,
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

  genInstallConfigScript = writeShellScript "xilinx-install" ''
    if [ -e /dev/fuse ]; then
      mkdir tar-write-overlay
      ratarmount --write-overlay ./tar-write-overlay $src ./unpack
    fi

    unpack=$(find ./unpack -mindepth 1 -maxdepth 1 -type d)

    echo -e "1\n1\n" | "$unpack/xsetup" \
      --agree ${lib.strings.escapeShellArg agreedLicenses} \
      --batch ConfigGen

    [ -e /dev/fuse ] && ratarmount -u /build/unpack
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

    [ -e /dev/fuse ] && ratarmount -u /build/unpack
  '';
in
stdenv.mkDerivation {
  pname = "${name}";
  inherit version;

  src = installTar;

  nativeBuildInputs = [
    util-linux
    rapidgzip
    (genXilinxFhs {
      runScript = "unshare -m -r bash";
      extraBwrapArgs = [ "--bind $out $out" ];
    })
  ];

  unpackPhase = ''
    runHook preUnpack

    if [ -e /dev/fuse ]; then
      echo "Found /dev/fuse. Using mounting (ratarmount) instead of unpacking."
    else
      echo "Unpacking archive. Use \"--extra-sandbox-paths /dev/fuse\" to skip unpacking and mounting the archive instead."
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
          xilinx-fhs ${genInstallConfigScript}
        ''
      else
        ''
          cp -- ${installConfig} ./.Xilinx/install_config.txt
          chmod a+rw ./.Xilinx/install_config.txt

          substituteInPlace ./.Xilinx/install_config.txt \
            --replace-fail /tools/Xilinx $out

          xilinx-fhs ${installScript}
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

  meta = {
    description = "AMD/Xilinx toolchain";
    homepage = "https://www.xilinx.com/products/design-tools/vivado.html";
    license = lib.licenses.unfree;
    maintainers = with lib.maintainers; [ wucke13 ];
    platforms = lib.platforms.unix;
  };
}
