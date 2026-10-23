{
  description = "Eric Merritt's personal system configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/cd4ea8d57de16f4810bc5f14207bac45fbf19f67";
    # Only the agent executables use this pin; the base system stays on stable.
    agent-nixpkgs.url = "github:NixOS/nixpkgs/7a6522c868711d06e3a520bbcdfafe9806f4337f";
    home-manager = {
      url = "github:nix-community/home-manager/24f8f8e786f87d6a818e1746cb2389bf922afdab";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    self,
    nixpkgs,
    agent-nixpkgs,
    home-manager,
    ...
  }: let
    systems = ["aarch64-darwin" "x86_64-linux"];
    forAllSystems = nixpkgs.lib.genAttrs systems;
  in {
    packages = forAllSystems (system: {
      inherit (agent-nixpkgs.legacyPackages.${system}) herdr pi-coding-agent;
    });

    nixosConfigurations.lascasas = nixpkgs.lib.nixosSystem {
      specialArgs.agentPackages = self.packages.x86_64-linux;
      modules = [
        home-manager.nixosModules.home-manager
        ./hosts/lascasas
        {nixpkgs.overlays = [self.overlays.default];}
      ];
    };

    homeManagerModules = {
      agents = import ./nix-home/personal/agents.nix;
      common = import ./nix-home/common.nix;
      darwin = import ./nix-home/darwin.nix;
      desktop = import ./nix-home/desktop.nix;
      helix = import ./nix-home/helix;
      wezterm = import ./nix-home/wezterm;
      zellij = import ./nix-home/zellij;
    };

    overlays.default = import ./overlays/zellij-attention.nix;

    checks = forAllSystems (system: let
      pkgs = nixpkgs.legacyPackages.${system};
    in {
      lascasas = import ./checks/assertions.nix {
        inherit pkgs;
        assertions = import ./checks/lascasas.nix {
          config = self.nixosConfigurations.lascasas.config;
        };
      };
    });

    devShells = forAllSystems (system: let
      pkgs = nixpkgs.legacyPackages.${system};
    in {
      default = pkgs.mkShell {
        packages = with pkgs; [git alejandra statix just python3 openssh ruff mypy nodejs_24 prettier];
        PI_SETTINGS_SDK = "${self.packages.${system}.pi-coding-agent}/lib/node_modules/pi-monorepo/dist/index.js";
      };
    });
  };
}
