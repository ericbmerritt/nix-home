{...}: {
  # wezterm itself (enable + the format-tab-title config) comes from the
  # whitepages-nix work profile; a stale duplicate of extraConfig here
  # concatenated with it into invalid Lua (two top-level `return {}`).
  # Keep only the zsh integration, which the work profile does not set.
  programs.wezterm.enableZshIntegration = true;
}
