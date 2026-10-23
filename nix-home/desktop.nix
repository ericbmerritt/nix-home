{pkgs, ...}: {
  imports = [./wezterm];

  home.packages = [pkgs.meld];
  programs.wezterm.enable = true;
}
