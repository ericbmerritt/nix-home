{
  pkgs,
  lib,
  ...
}:
pkgs.rustPlatform.buildRustPackage rec {
  pname = "lsp-ai";
  version = "v0.3.5";

  src = pkgs.fetchFromGitHub {
    owner = "SilasMarvin";
    repo = "lsp-ai";
    rev = "v0.6.1";
    sha256 = "sha256-bxSleKi8OKTHfGNhfjVMW6LarpzicjgavTN7DLivSpk=";
  };

  cargoLock = {
    lockFile = "${src}/Cargo.lock";
    outputHashes = {
      "hf-hub-0.3.2" = "sha256-1AcishEVkTzO3bU0/cVBI2hiCFoQrrPduQ1diMHuEwo=";
      "tree-sitter-zig-0.0.1" = "sha256-UXJCh8GvXzn+sssTrIsLViXD3TiBZhLFABYCKM+fNMQ=";
    };
  };
  doCheck = false;

  nativeBuildInputs = [pkgs.pkg-config];

  buildInputs =
    [pkgs.openssl.dev pkgs.cacert]
    ++ lib.optionals pkgs.stdenv.isDarwin (with pkgs.darwin.apple_sdk; [
      frameworks.Security
      frameworks.CoreFoundation
      frameworks.SystemConfiguration
    ]);

  # Needed to get openssl-sys to use pkg-config.
  # Doesn't seem to like OpenSSL 3
  OPENSSL_NO_VENDOR = 1;
  PKG_CONFIG_PATH = "${pkgs.openssl.dev}/lib/pkgconfig";
}
