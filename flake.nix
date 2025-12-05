{
  description = "emerritt's nix-darwin configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    nix-darwin = {
      url = "github:LnL7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    pagecraft = {
      url = "git+ssh://git@github.dev.pages/whitepages-meta/monorepo?dir=tools/pagecraft&ref=push-ylpyytrrynxs";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    whitepages-nix = {
      url = "git+ssh://git@github.dev.pages/whitepages-meta/monorepo?dir=nix&ref=push-ylpyytrrynxs";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        home-manager.follows = "home-manager";
        pagecraft.follows = "pagecraft";
      };
    };
  };

  outputs = {
    self,
    nix-darwin,
    home-manager,
    whitepages-nix,
    ...
  }: let
    configuration = {pkgs, ...}: {
      ids.gids.nixbld = 350;

      nix = {
        package = pkgs.nix;
        enable = false;
        settings = {
          experimental-features = "nix-command flakes";
          trusted-users = ["root" "emerritt"];
          substituters = [
            "https://cache.nixos.org"
            "https://devenv.cachix.org"
          ];
          trusted-substituters = [
            "https://cache.nixos.org"
            "https://devenv.cachix.org"
          ];
          trusted-public-keys = [
            "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
            "devenv.cachix.org-1:w1cLUi8dv3hnoSPGAuibQv+f9TZLr6cv/Hm9XgU50cw="
          ];
        };
        extraOptions =
          ''
            download-buffer-size = 50M
            auto-optimise-store = true
          ''
          + pkgs.lib.optionalString (pkgs.stdenv.hostPlatform.system == "aarch64-darwin") ''
            extra-platforms = x86_64-darwin aarch64-darwin
          '';
      };

      programs.zsh.enable = true;

      homebrew = {
        enable = true;
        brews = ["awscli@2"];
      };

      system = {
        configurationRevision = self.rev or self.dirtyRev or null;
        stateVersion = 4;
        primaryUser = "emerritt";
      };

      nixpkgs.hostPlatform = "aarch64-darwin";
    };
  in {
    darwinConfigurations."wp-K942Q6VXR7" = nix-darwin.lib.darwinSystem {
      modules = [
        {nixpkgs.config.allowUnfreePredicate = _: true;}
        configuration
        home-manager.darwinModules.home-manager
        {
          users.users.emerritt.home = "/Users/emerritt";
          home-manager = {
            useGlobalPkgs = true;
            useUserPackages = true;
            users.emerritt = {
              imports = [
                ./nix-home/common.nix
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
      ];
    };

    darwinPackages = self.darwinConfigurations."wp-K942Q6VXR7".pkgs;
  };
}
