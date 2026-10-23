{
  pkgs,
  lib,
  personal,
  whitepages-nix,
  configurationRevision,
  ...
}: let
  identity = {
    name = "Eric Merritt";
    email = "emerritt@whitepages.com";
  };
in {
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
        (personal.outPath + "/nix-home/common.nix")
        (personal.outPath + "/nix-home/darwin.nix")
        (personal.outPath + "/nix-home/desktop.nix")
        whitepages-nix.homeManagerModules.work
      ];
      whitepages.workProfile.enable = true;
      home = {
        username = "emerritt";
        stateVersion = "23.05";
        packages = [pkgs.herdr];
      };
      programs = {
        git.settings.user = identity;
        jujutsu.settings.user = identity;
        ssh.settings = {
          "github.dev.pages".IdentityFile = "~/.ssh/id_ed25519";
          "lascasas" = {
            HostName = "lascasas";
            User = "eric";
          };
        };
      };

      # The work profile points netrc-file at ~/.config/nix/netrc, but
      # Determinate owns netrc. Extra cache credentials are merged into its
      # file by authentication.additionalNetrcSources in Determinate's config.
      nix.settings.netrc-file = lib.mkForce "/nix/var/determinate/netrc";
    };
  };
}
