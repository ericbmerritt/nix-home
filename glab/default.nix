{ stdenv, fetchurl }:

# This fetches the glab
stdenv.mkDerivation rec {
  version = "1.8.1";
  name = "glab-v${version}";

  src = fetchurl {
    url =
      "https://github.com/profclems/glab/releases/download/v${version}/glab_${version}_Linux_x86_64.tar.gz";
    sha256 = "0628hlji3zbvl3ci9x1qi57wp92rpxrf72dpxp61h0llnbidbsx3";
  };

  phases = [ "unpackPhase" "installPhase" ];
  unpackPhase = ''
    tar xzf $src
  '';

  installPhase = ''

    mkdir -p $out/bin
    cp ./glab $out/bin/glab
    chmod a+x $out/bin/glab
  '';
}

