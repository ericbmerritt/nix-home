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

    # Re-sign the outer bundle. Restricted entitlements (application-
    # identifier, team-identifier, keychain-access-groups, ...) are only valid
    # with a real Apple-issued certificate; keeping them under an ad-hoc
    # signature makes amfid kill the process with SIGKILL (-424). Keep only
    # the unrestricted ones.
    # NOTE: no --deep -- it mangles Sparkle's nested helpers.
    cat > entitlements.plist <<'EOF'
    <?xml version="1.0" encoding="UTF-8"?>
    <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
    <plist version="1.0">
    <dict>
      <key>com.apple.security.cs.allow-jit</key><true/>
      <key>com.apple.security.cs.allow-unsigned-executable-memory</key><true/>
      <key>com.apple.security.cs.disable-library-validation</key><true/>
      <key>com.apple.security.automation.apple-events</key><true/>
      <key>com.apple.security.device.audio-input</key><true/>
      <key>com.apple.security.device.camera</key><true/>
    </dict>
    </plist>
    EOF
    /usr/bin/codesign --force --sign - \
      --entitlements entitlements.plist \
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
