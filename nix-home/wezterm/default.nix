{lib, ...}: {
  # wezterm itself (enable) comes from the whitepages-nix work profile.
  # extraConfig is types.lines, so contributions normally concatenate --
  # but this file's extra-config.lua ends in `return config`, and Lua
  # allows only one `return` per chunk, so it can't coexist by
  # concatenation with the work profile's own `return {}`
  # (nix/wp-home-manager/modules/work.nix). mkForce replaces the work
  # profile's contribution instead of concatenating with it; extra-config.lua
  # duplicates the work profile's format-tab-title handler so nothing is
  # lost by fully overriding it. See the comment at the bottom of
  # extra-config.lua for the full story.
  programs.wezterm.enableZshIntegration = true;
  programs.wezterm.extraConfig = lib.mkForce (builtins.readFile ./extra-config.lua);
}
