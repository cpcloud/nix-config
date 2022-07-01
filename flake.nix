{
  description = "cpcloud's NixOS config";

  inputs = {
    deploy-rs = {
      url = "github:serokell/deploy-rs";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        utils.follows = "utils";
        flake-compat.follows = "flake-compat";
      };
    };

    flake-compat = {
      url = "github:edolstra/flake-compat";
      flake = false;
    };

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-index-database = {
      url = "github:Mic92/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixos-hardware = {
      url = "github:NixOS/nixos-hardware";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable-small";

    pre-commit-hooks = {
      url = "github:cachix/pre-commit-hooks.nix";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-utils.follows = "utils";
    };

    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    templates = {
      url = "github:NixOS/templates";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    utils = {
      url = "github:numtide/flake-utils";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, utils, nix-index-database, ... }@inputs: {
    deploy = import ./nix/deploy.nix inputs;
    overlays = {
      default = import ./nix/overlay.nix inputs;
    };
    homeConfigurations = import ./nix/home-manager.nix inputs;
    nixosConfigurations = import ./nix/nixos.nix inputs;
  } // utils.lib.eachSystem
    [ "aarch64-linux" "x86_64-linux" "aarch64-darwin" "x86_64-darwin" ]
    (system: {
      checks = import ./nix/checks.nix inputs system;

      devShells.default = import ./nix/dev-shell.nix inputs system;

      packages = {
        default = self.packages.${system}.all;
      } // (import ./nix/host-drvs.nix inputs system);

      nixpkgs = import nixpkgs {
        inherit system;
        overlays = [
          self.overlays.default
          (_: _: { nix-index-database = nix-index-database.legacyPackages.${system}.database; })
        ];
        config = {
          allowUnfree = true;
          allowAliases = true;
        };
      };
    });
}
