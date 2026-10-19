{
  pkgs,
  personal,
  whitepages-nix,
  configurationRevision,
  ...
}: {
  ids.gids.nixbld = 350;

  nix = {
    package = pkgs.nix;
    enable = false;
  };

  programs.zsh.enable = true;

  homebrew = {
    enable = true;
    brews = [];
    casks = [];
  };

  system = {
    inherit configurationRevision;
    stateVersion = 4;
    primaryUser = "emerritt";
  };

  nixpkgs = {
    hostPlatform = "aarch64-darwin";
    config.allowUnfreePredicate = _: true;
    overlays = [
      personal.overlays.default
      (_: prev: {
        direnv = prev.direnv.overrideAttrs (_: {doCheck = false;});
      })
    ];
  };

  users.users.emerritt.home = "/Users/emerritt";
  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    backupFileExtension = "hm-bak";
    users.emerritt = {
      imports = [
        # The legacy mixed home module remains work-only until phase 2.
        (personal.outPath + "/nix-home/common.nix")
        whitepages-nix.homeManagerModules.work
      ];
      whitepages.workProfile.enable = true;
      home = {
        username = "emerritt";
        stateVersion = "23.05";
      };
    };
  };
}
