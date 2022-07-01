{ self, home-manager, nixpkgs, templates, nix-index-database, ... }:
let
  inherit (nixpkgs) lib;
  hosts = (import ./hosts.nix).homeManager.all;

  genModules = hostName: localSystem:
    { config, ... }: {
      imports = [ (../hosts + "/${hostName}") ];
      nix.registry = {
        templates.flake = templates;
        nixpkgs.flake = nixpkgs;
      };

      home.sessionVariables.NIX_PATH = lib.concatStringsSep ":" [
        "nixpkgs=${config.xdg.dataHome}/nixpkgs"
        "nixpkgs-overlays=${config.xdg.dataHome}/overlays"
      ];
      home.file.".cache/nix-index/files".source = nix-index-database.${localSystem}.database;

      xdg = {
        dataFile = {
          nixpkgs.source = nixpkgs;
          overlays.source = ../nix/overlays;
        };
        configFile."nix/nix.conf".text = ''
          flake-registry = ${config.xdg.configHome}/nix/registry.json
        '';
      };
    };

  genConfiguration = hostName: { homeDirectory, localSystem, username, ... }:
    home-manager.lib.homeManagerConfiguration {
      inherit homeDirectory username;
      configuration = genModules hostName localSystem;
      pkgs = self.nixpkgs.${localSystem};
      stateVersion = import ./state-version.nix;
      system = localSystem;
    };
in
lib.mapAttrs genConfiguration hosts
