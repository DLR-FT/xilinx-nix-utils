{
  lib,
  stdenv,
  genXilinxFhs,
  rapidgzip,
  ripgrep,
  xorg,

  name,
  version,
  installTar,
  install_config ? null,
  agreements ? [
    "3rdPartyEULA"
    "XilinxEULA"
  ],
}:
stdenv.mkDerivation (
  finalAttrs:
  let
    # nameLowercase = lib.strings.toLower name;

    # TODO verify the statement below
    # The installer will refuse to install to any directory for which at least one ancestor dir
    # is writable. Thus is impossible to directly install to $out, because /nix/store itself might
    # be ro.
    uniqueTargetDir = "/build/very_unique_target_install_dir";

    # licenses that the user agreed to
    agreedLicenses = lib.strings.concatStringsSep "," agreements;
  in
  # Formats a str bool pair to a format understood by Xilinx' installer config parser
  #toColonInt = name: value: if value then "${name}:1" else "${name}:0";
  # List of products and their state (enabled/disabled) for the installer config
  #selectedProducts = lib.strings.concatStringsSep "," (lib.attrsets.mapAttrsToList toColonInt products);
  {
    pname = name;
    inherit version;

    src = installTar;

    nativeBuildInputs = [
      rapidgzip
      ripgrep
      xorg.xorgserver
      (genXilinxFhs { })
    ];

    # the installer puts stuff to $HOME/.Xilinx
    preUnpack = ''
      export HOME="$PWD"
    '';

    # for the 100+ GB normal gzip takes forever to decompress
    unpackCmd = ''
      if [[ $src == *.tar.gz ]]; then
        rapidgzip --decompress --stdout "$src" | tar --extract
      elif [[ $src == *.tar ]]; then
        cat $src | tar --extract
      fi
    '';

    # 1. launch a fake X server, the installer needs it even in batch mode
    # 2. generate an installer config, mutate it to do the right thing
    # 3. run installer with the changed config
    # 4. clean up X server
    # 5. move installation to /nix/store
    #    - directly installing to there is not possible, due to a bug in the xilinx installer
    #    - the installer requires all ancestor dirs of the installation to be writable
    installPhase = ''
      runHook preInstall

      export DISPLAY=:1
      Xvfb $DISPLAY &
      xvfb_pid=$!

      ${
        if !(builtins.isNull install_config) then
          ''
            mkdir -p $HOME/.Xilinx
            cp -- ${install_config} $HOME/.Xilinx/install_config.txt
            chmod u=rw $HOME/.Xilinx/install_config.txt
            INSTALL_CONFIG="$HOME/.Xilinx/install_config.txt"
          ''
        else
          ''
            echo -e "1\n1\n" | xilinx-fhs xsetup \
              --agree ${lib.strings.escapeShellArg agreedLicenses} \
              --batch ConfigGen
            INSTALL_CONFIG="$HOME/.Xilinx/install_config.txt"
          ''
      }

      echo "### Begin of Install Config ###"
      cat "$INSTALL_CONFIG"
      echo "### End of Install Config ###"

      substituteInPlace "$INSTALL_CONFIG" \
        --replace-fail /tools/Xilinx ${lib.strings.escapeShellArg uniqueTargetDir}

      xilinx-fhs xsetup \
        --agree ${lib.strings.escapeShellArg agreedLicenses} \
        --batch Install \
        --config "$INSTALL_CONFIG" \
        --xdebug

      kill $xvfb_pid

      mv ${lib.strings.escapeShellArg uniqueTargetDir} "$out"
      mv "$HOME/.Xilinx" "$out/"

      runHook postInstall
    '';

    # update the installation target dir
    preFixup = ''
      while IFS= read -r -d "" file ; do
        substituteInPlace "$file" \
          --replace-fail ${lib.strings.escapeShellArg uniqueTargetDir} "$out"
      done < <(rg --null --files-with-matches ${lib.strings.escapeShellArg uniqueTargetDir} "$out")
    '';
    # sed 's:'${lib.strings.escapeShellArg uniqueTargetDir}":$out:g" \
    #   --in-place -- "$file"

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
)
