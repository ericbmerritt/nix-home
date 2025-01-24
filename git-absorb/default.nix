{ pkgs ? import <nixpkgs> {} }:

let
  # Pull in some conveniences from pkgs
  lib = pkgs.lib;

  # The Rust toolchain (includes Rustc, Cargo, etc.)
  rustPlatform = pkgs.rustPlatform;
in
rustPlatform.buildRustPackage rec {
  pname = "git-absorb";
  # Pick a version or commit
  version = "0.6.17";

  # Fetch the source from GitHub
  src = pkgs.fetchFromGitHub {
    owner  = "tummychow";
    repo   = "git-absorb";
    # Replace 'v0.7.3' with your desired tag or commit SHA
    rev    = version;
    # Replace this with the actual sha256 you get from a prefetch
    sha256 = "sha256-wtXqJfI/I0prPip3AbfFk0OvPja6oytPsl6hFtZ6b50=";
  };

  cargoHash = "sha256-R9hh696KLoYUfJIe3X4X1VHOpPmv1fhZ55y8muVAdRI=";
  doCheck = false;
  
  meta = with lib; {
    description = "This is a port of Facebook's hg absorb,";
    homepage    = "https://github.com/tummychow/git-absorb";
    license     = licenses.bsd3;
    maintainers = [ ];
    platforms   = platforms.all;
  };
}
