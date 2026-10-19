{flake}: let
  config = flake.darwinConfigurations."wp-K942Q6VXR7".config;
  home = config.home-manager.users.emerritt;
  inherit (flake.inputs.nixpkgs) lib;
  packageNames = packages: lib.sort builtins.lessThan (map (package: package.name) packages);
in {
  pins = {
    nixpkgs = flake.inputs.nixpkgs.rev;
    homeManager = flake.inputs.home-manager.rev;
    nixDarwin = flake.inputs.nix-darwin.rev;
    unstable = flake.inputs.whitepages-nix.inputs.nixpkgs-unstable.rev;
  };
  host = {
    platform = config.nixpkgs.hostPlatform.system;
    stateVersion = config.system.stateVersion;
    primaryUser = config.system.primaryUser;
    nixEnabled = config.nix.enable;
    homeDirectory = config.users.users.emerritt.home;
  };
  user = {
    stateVersion = home.home.stateVersion;
    packages = packageNames home.home.packages;
    sessionPath = home.home.sessionPath;
    git = home.programs.git.settings;
    jujutsu = home.programs.jujutsu.settings;
    ssh = home.programs.ssh.settings;
    helix = home.programs.helix.settings;
    wezterm = home.programs.wezterm.extraConfig;
    zellij = home.xdg.configFile."zellij/config.kdl".text;
    managedFiles = builtins.attrNames home.home.file;
    activationJobs = builtins.attrNames home.home.activation;
  };
  systemPackages = packageNames config.environment.systemPackages;
}
