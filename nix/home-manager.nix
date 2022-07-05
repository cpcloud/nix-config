{ self, home-manager, nixpkgs, templates, ... }:
let
  inherit (nixpkgs) lib;
  hosts = (import ./hosts.nix).homeManager.all;

  genModules = hostName:
    { config, ... }: {
      imports = [ (../hosts + "/${hostName}") ];
      nix.registry = {
        templates.flake = templates;
        nixpkgs.flake = nixpkgs;
      };

      home.sessionVariables = {
        NIX_PATH = lib.concatStringsSep ":" [
          "nixpkgs=${config.xdg.dataHome}/nixpkgs"
          "nixpkgs-overlays=${config.xdg.dataHome}/overlays"
        ];
        MOZ_DBUS_REMOTE = 1;
        MOZ_USE_XINPUT2 = 1;
        _JAVA_OPTIONS = "-Dawt.useSystemAAFontSettings=on -Dswing.aatext=true -Dsun.java2d.xrender=true";
      };

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
      configuration = genModules hostName;
      pkgs = self.nixpkgs.${localSystem};
      stateVersion = import ./state-version.nix;
      system = localSystem;
    };
in
lib.mapAttrs genConfiguration hosts
