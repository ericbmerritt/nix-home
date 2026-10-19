{
  description = "Eric Merritt's personal system configuration";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/cd4ea8d57de16f4810bc5f14207bac45fbf19f67";

  outputs = {
    self,
    nixpkgs,
    ...
  }: let
    systems = ["aarch64-darwin" "x86_64-linux"];
    forAllSystems = nixpkgs.lib.genAttrs systems;
  in {
    nixosConfigurations.lascasas = nixpkgs.lib.nixosSystem {
      modules = [./hosts/lascasas];
    };

    homeManagerModules = {
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
        packages = with pkgs; [git alejandra statix just python3 openssh ruff mypy];
      };
    });
  };
}
