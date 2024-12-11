{ config, pkgs, ... }:

let
  # Define the path to the encrypted file and where to store the decrypted output
  secretsDir = "${config.home.homeDirectory}/.secrets";
  decryptedFile = "${secretsDir}/environment-file.sh";
in
{
    
  # Decrypt the file during activation
  home.activation.decryptSecret = pkgs.lib.mkAfter ''

    # Create the .secrets directory if it doesn't exist
    mkdir -p ${secretsDir}

  '';

  # Source the decrypted file into session variables
  home.sessionVariablesExtra = ''
    source ${decryptedFile}
  '';
}



