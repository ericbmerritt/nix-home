{
  lib,
  buildNpmPackage,
  fetchFromGitHub,
}:
buildNpmPackage rec {
  pname = "gsd";
  version = "1.9.13"; # pin intentionally

  src = fetchFromGitHub {
    owner = "glittercowboy";
    repo = "get-shit-done";
    rev = "v${version}";
    hash = "sha256-zm6Qr5Fk8AvlG7PcJOGBeed+PfbEPzE0swIljlgzyuY=";
  };

  npmDepsHash = "sha256-CSkq0PfYJJ7ZRx6vrxWdTAWJCGPhba0yIEDeBEYDI6k=";

  dontNpmBuild = true;

  postInstall = ''
    ln -s $out/bin/get-shit-done-cc $out/bin/gsd

    # Install assets for home-manager module
    mkdir -p $out/share/gsd
    cp -r $src/agents $out/share/gsd/
    cp -r $src/commands $out/share/gsd/
    cp -r $src/get-shit-done $out/share/gsd/
    # hooks/dist may not exist in source; try dist first, fall back to hooks/
    if [ -d "$src/hooks/dist" ]; then
      cp -r $src/hooks/dist $out/share/gsd/hooks
    else
      mkdir -p $out/share/gsd/hooks
      cp $src/hooks/*.js $out/share/gsd/hooks/ || true
      cp $src/hooks/*.sh $out/share/gsd/hooks/ || true
    fi

    # Write version file
    echo "${version}" > $out/share/gsd/VERSION
  '';

  passthru = {
    inherit src version;
  };

  meta = with lib; {
    description = "CLI to install configuration for Claude Code / OpenCode / Cursor";
    homepage = "https://github.com/glittercowboy/get-shit-done";
    license = licenses.mit;
    mainProgram = "gsd";
    platforms = platforms.unix;
  };
}
