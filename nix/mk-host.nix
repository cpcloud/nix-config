{ pkgs
, inputs
, name
, system
, extraModules ? [ ]
}:
let
  inherit (pkgs.lib) mapAttrs' nameValuePair;
  inherit (inputs) sops-nix home-manager;
  inherit (inputs.nixpkgs.lib) nixosSystem;
in
nixosSystem {
  inherit system;

  modules = [
    home-manager.nixosModules.home-manager
    sops-nix.nixosModules.sops

    { nixpkgs = { inherit (pkgs) config overlays; }; }

    {
      nix.registry = {
        self.flake = inputs.self;
        template = {
          flake = inputs.templates;
          from = {
            id = "templates";
            type = "indirect";
          };
        };
        nixpkgs = {
          flake = inputs.nixpkgs;
          from = {
            id = "nixpkgs";
            type = "indirect";
          };
        };
      };
    }

    {
      networking.hosts = mapAttrs' (n: v: nameValuePair v.hostname [ n ]) (import ./hosts.nix);
    }

    (../hosts + "/${name}")
  ] ++ extraModules;

  specialArgs.inputs = inputs;
}
