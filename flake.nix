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
      url = "git+ssh://git@github.dev.pages/whitepages-meta/monorepo?dir=tools/pagecraft&ref=main";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    whitepages-nix = {
      url = "git+ssh://git@github.dev.pages/whitepages-meta/monorepo?dir=nix/wp-home-manager&ref=main";
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
      };

      programs.zsh.enable = true;

      homebrew = {
        enable = true;
        brews = ["awscli@2"];
        casks = ["nikitabobko/tap/aerospace"];
      };

      system = {
        configurationRevision = self.rev or self.dirtyRev or null;
        stateVersion = 4;
        primaryUser = "emerritt";
      };

      nixpkgs.hostPlatform = "aarch64-darwin";
    };
    overlays.default = final: prev: {
      gsd = final.callPackage ./nix-home/get-shit-done {};
    };
  in {
    darwinConfigurations."wp-K942Q6VXR7" = nix-darwin.lib.darwinSystem {
      modules = [
        {
          nixpkgs.config.allowUnfreePredicate = _: true;
          nixpkgs.overlays = [overlays.default];
        }
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
                ./nix-home/get-shit-done/module.nix
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
