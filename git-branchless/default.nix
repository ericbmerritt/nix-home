{ pkgs ? import <nixpkgs> {} }:

let
  lib = pkgs.lib;
  rustPlatform = pkgs.rustPlatform;
in
rustPlatform.buildRustPackage rec {
  pname = "git-branchless";
  version = "0.10.0";

  src = pkgs.fetchFromGitHub {
    owner  = "arxanas";
    repo   = "git-branchless";
    rev    = "v${version}";
    sha256 = "sha256-8uv+sZRr06K42hmxgjrKk6FDEngUhN/9epixRYKwE3U=";
  };

  cargoHash = "sha256-AEEAHMKGVYcijA+Oget+maDZwsk/RGPhHQfiv+AT4v8=";
  doCheck = false;
  
  meta = with lib; {
    description = "A suite of tools to help visualize and organize Git commits more efficiently";
    homepage    = "https://github.com/arxanas/git-branchless";
    license     = licenses.mit;
    maintainers = [ ];
    platforms   = platforms.all;
  };
}
