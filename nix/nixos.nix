{ self
, home-manager
, nixos-hardware
, nixpkgs
, templates
, sops-nix
, ...
}:
let
  inherit (nixpkgs) lib;
  hosts = (import ./hosts.nix).nixos.all;

  nixRegistry = {
    nix.registry = {
      templates.flake = templates;
      nixpkgs.flake = nixpkgs;
    };
  };

  hostPkgs = localSystem: {
    nixpkgs = {
      localSystem.system = localSystem;
      pkgs = self.nixpkgs.${localSystem};
    };
  };

  genConfiguration = hostname: { localSystem, ... }:
    lib.nixosSystem {
      system = localSystem;
      modules = [
        (../hosts + "/${hostname}")
        (hostPkgs localSystem)
        nixRegistry
        home-manager.nixosModules.home-manager
        sops-nix.nixosModules.sops
      ];
      specialArgs = {
        nixos-hardware = nixos-hardware.nixosModules;
      };
    };
in
lib.mapAttrs genConfiguration hosts
