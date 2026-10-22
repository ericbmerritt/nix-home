{
  imports = [../../nix-home/personal/agents.nix];

  fonts.fontconfig.enable = false;

  home = {
    username = "eric";
    homeDirectory = "/home/eric";
    stateVersion = "26.05";
  };
}
