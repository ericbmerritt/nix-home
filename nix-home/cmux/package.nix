{
  lib,
  stdenvNoCC,
  fetchurl,
  _7zz,}:
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "cmux";
  version = "0.64.22";

  src = fetchurl {
    url = "https://github.com/manaflow-ai/cmux/releases/download/v${finalAttrs.version}/cmux-macos.dmg";
    hash = "sha256-/RSNujUZ/n0wiEQInOTQYrF3ObpkViPwWPZ6ZHmM6iU=";
  };

  nativeBuildInputs = [_7zz];

  # The DMG is an APFS image; only 7-Zip >= 24 can extract it, and it
  # materializes the code-signature extended attributes as literal
  # "<file>:com.apple.cs.*" files. The Nix store does not preserve xattrs
  # regardless, so we remove them and re-sign the bundle ad-hoc.
  dontBuild = true;

  unpackPhase = ''
    runHook preUnpack
    7zz x $src -o.
    rm .DS_Store .VolumeIcon.icns
    runHook postUnpack
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/Applications $out/bin
    cp -R cmux.app $out/Applications/

    # The app binary doubles as the CLI.
    ln -s $out/Applications/cmux.app/Contents/MacOS/cmux $out/bin/cmux

    runHook postInstall
  '';

  postFixup = ''
    # Strip the stray xattr-materialized files 7zz left behind.
    find $out/Applications/cmux.app -name '*:com.apple.cs.*' -delete

    # Re-sign only the outer bundle so it matches the (still-valid) nested
    # code and the script shebangs fixup rewrote. Entitlements and requirements
    # are carried over from the original signature.
    # NOTE: no --deep -- it mangles Sparkle's nested helpers.
    /usr/bin/codesign --force --sign - \
      --preserve-metadata=entitlements,requirements,flags \
      $out/Applications/cmux.app
  '';

  meta = {
    description = "Ghostty-based macOS terminal with vertical tabs and notifications for AI coding agents";
    homepage = "https://cmux.com";
    changelog = "https://github.com/manaflow-ai/cmux/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.gpl3Plus;
    platforms = lib.platforms.darwin;
    sourceProvenance = [lib.sourceTypes.binaryNativeCode];
  };
})
