{
  description = "Private inputs and wiring for the Whitepages laptop";

  inputs = {
    personal.url = "path:../..";
    nixpkgs.follows = "whitepages-nix/nixpkgs";
    nix-darwin.follows = "whitepages-nix/nix-darwin";
    home-manager.follows = "whitepages-nix/home-manager";

    # Keep both subflakes on the same published monorepo revision.
    pagecraft = {
      url = "git+ssh://git@github.dev.pages/whitepages-meta/monorepo?dir=tools/pagecraft&rev=9643e6f90942034b46240cf288dbbe482cd8770c";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    whitepages-nix = {
      url = "git+ssh://git@github.dev.pages/whitepages-meta/monorepo?dir=nix/wp-home-manager&rev=9643e6f90942034b46240cf288dbbe482cd8770c";
      inputs.pagecraft.follows = "pagecraft";
    };
  };

  outputs = {
    self,
    personal,
    nixpkgs,
    nix-darwin,
    home-manager,
    whitepages-nix,
    ...
  }: {
    darwinConfigurations."wp-K942Q6VXR7" = nix-darwin.lib.darwinSystem {
      specialArgs = {
        inherit personal whitepages-nix;
        configurationRevision = self.rev or self.dirtyRev or null;
      };
      modules = [
        home-manager.darwinModules.home-manager
        (personal.outPath + "/hosts/wp-K942Q6VXR7")
      ];
    };

    darwinPackages = self.darwinConfigurations."wp-K942Q6VXR7".pkgs;

    checks.aarch64-darwin.work-laptop = import (personal.outPath + "/checks/assertions.nix") {
      pkgs = nixpkgs.legacyPackages.aarch64-darwin;
      assertions = import (personal.outPath + "/checks/work-laptop.nix") {flake = self;};
    };

    devShells.aarch64-darwin.default = let
      pkgs = nixpkgs.legacyPackages.aarch64-darwin;
    in
      pkgs.mkShell {
        packages = with pkgs; [git alejandra statix just python3];
      };
  };
}
