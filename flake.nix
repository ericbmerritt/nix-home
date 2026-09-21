{
  description = "emerritt's nix-darwin configuration";

  inputs = {
    nixpkgs.follows = "whitepages-nix/nixpkgs";
    nix-darwin.follows = "whitepages-nix/nix-darwin";
    home-manager.follows = "whitepages-nix/home-manager";

    pagecraft = {
      # Temporarily track the local stack-herdr work; restore the git+ssh
      # main URL once this stack merges.
      url = "git+file:///Users/emerritt/workspace/monorepo-stacks/stacks/stack-herdr?dir=tools/pagecraft";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    whitepages-nix = {
      # Temporarily track the local stack-herdr work; restore the git+ssh
      # main URL once this stack merges.
      url = "git+file:///Users/emerritt/workspace/monorepo-stacks/stacks/stack-herdr?dir=nix/wp-home-manager";
      inputs.pagecraft.follows = "pagecraft";
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
        brews = [];
        casks = [];
      };

      system = {
        configurationRevision = self.rev or self.dirtyRev or null;
        stateVersion = 4;
        primaryUser = "emerritt";
      };

      nixpkgs.hostPlatform = "aarch64-darwin";
    };
    overlays.default = final: prev: {
      direnv = prev.direnv.overrideAttrs (old: {doCheck = false;});
      zellij-attention = final.fetchurl {
        url = "https://github.com/KiryuuLight/zellij-attention/releases/download/v0.3.0/zellij-attention.wasm";
        sha256 = "1a6b6cy8fsghc28lmyjwwp5l20xvfyhyi1awlmb11fn1ls573b89";
      };
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
            # Unmanaged files that land where a home-manager symlink belongs
            # (hand-installed agent skills, editor state) otherwise abort the
            # whole activation. Move them aside instead of failing the switch.
            backupFileExtension = "hm-bak";
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

    devShells.aarch64-darwin.default = let
      pkgs = import self.inputs.nixpkgs {system = "aarch64-darwin";};
    in
      pkgs.mkShell {
        packages = with pkgs; [git alejandra statix just];
      };
  };
}
