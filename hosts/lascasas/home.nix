let
  identity = {
    name = "Eric Merritt";
    email = "eric@merritt.tech";
  };
in {
  imports = [../../nix-home/common.nix ../../nix-home/personal/agents.nix];

  programs = {
    bash.enable = true;
    git.settings.user = identity;
    jujutsu.settings.user = identity;
    # Persistent Herdr/Pi sessions can retain a dead inherited agent socket.
    ssh.settings."*".IdentityAgent = "/run/user/%i/ssh-agent";
  };

  fonts.fontconfig.enable = false;

  home = {
    username = "eric";
    homeDirectory = "/home/eric";
    stateVersion = "26.05";
  };
}
