{ config, pkgs, ... }:

{
  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  # Home Manager needs a bit of information about you and the
  # paths it should manage.
  imports = [ ./common.nix ];

  home.sessionVariablesExtra = ''
    . $HOME/.nix-profile/etc/profile.d/nix.sh
    PYENV_ROOT="$HOME/.pyenv"
    export PATH=$PATH:~/.cargo/bin:$PYENV_ROOT/shims
  '';

}
