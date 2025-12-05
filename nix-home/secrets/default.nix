{
  config,
  pkgs,
  ...
}: let
  # Define the path to the encrypted file and where to store the decrypted output
  secretsDir = "${config.home.homeDirectory}/.secrets";
  decryptedFile = "${secretsDir}/environment-file.sh";
in {
  # Source the decrypted file into session variables
  home.sessionVariablesExtra = ''
    source ${decryptedFile}
  '';
}
