{ self
, sops-nix
, deploy-rs
, nixpkgs
, pre-commit-hooks
, ...
}@inputs:
let
  system = "x86_64-linux";

  inherit (builtins) attrNames readDir;
  pkgs = import nixpkgs rec {
    inherit system;

    overlays = (map
      (f: import (./overlays + "/${f}") { inherit config; })
      (attrNames (readDir ./overlays)));

    config = {
      allowUnfree = true;
      allowAliases = true;
    };
  };

  inherit (pkgs.lib) joinHostDrvs mapAttrs mkForce;
in
{
  defaultPackage.${system} = self.packages.${system}.hosts;

  packages.${system}.hosts = joinHostDrvs "hosts"
    (mapAttrs (_: v: v.profiles.system.path) self.deploy.nodes);

  devShell.${system} = pkgs.callPackage ./shell.nix {
    inherit (sops-nix.packages.${system}) sops-import-keys-hook;
    inherit (deploy-rs.packages.${system}) deploy-rs;
    inherit (self.checks.${system}) pre-commit-check;
  };

  checks.${system} = (deploy-rs.lib."${system}".deployChecks self.deploy) // {
    pre-commit-check = pre-commit-hooks.lib."${system}".run {
      src = ../.;
      tools = pkgs;
      hooks = {
        nix-linter = {
          enable = true;
          entry = mkForce "${pkgs.nix-linter}/bin/nix-linter";
          excludes = [
            "flake.nix"
          ];
        };

        nixpkgs-fmt = {
          enable = true;
          entry = mkForce "${pkgs.nixpkgs-fmt}/bin/nixpkgs-fmt --check";
        };

        eslint = {
          # TODO: this check requires node_modules, but the check runs out of
          # the nix store and seems to ignore gitignore'd things
          enable = false;
          entry = pkgs.lib.mkForce "${pkgs.nodePackages.eslint}/bin/eslint";
          files = "\\.ts$";
        };

        prettier = {
          enable = true;
          entry = mkForce "${pkgs.prettierWithToml}/bin/prettier --check";
          types_or = mkForce [ "toml" "yaml" "json" "markdown" ];
        };

        shellcheck = {
          enable = true;
          entry = mkForce "${pkgs.shellcheck}/bin/shellcheck";
          files = "\\.sh$";
          types_or = mkForce [ ];
        };

        shfmt = {
          enable = true;
          entry = mkForce "${pkgs.shfmt}/bin/shfmt -i 2 -sr -d -s -l";
          files = "\\.sh$";
        };

        stylua = {
          enable = true;
          entry = mkForce "${pkgs.styluaWithFormat}/bin/stylua --check --verify";
          files = "\\.lua$";
        };
      };
    };
  };
} // (import ./deploy.nix pkgs system inputs)
