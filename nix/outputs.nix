{ self
, sops-nix
, deploy-rs
, nixpkgs
, pre-commit-hooks
, flake-utils
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
flake-utils.lib.eachSystem [ system ] (system:
  {
    defaultPackage = self.packages.hosts;

    packages.hosts = joinHostDrvs "hosts"
      (mapAttrs (_: v: v.profiles.system.path) self.deploy.${system}.nodes);

    devShell = pkgs.callPackage ./shell.nix {
      inherit (sops-nix.packages.${system}) sops-import-keys-hook;
      inherit (deploy-rs.packages.${system}) deploy-rs;
      inherit (self.checks.${system}) pre-commit-check;
    };

    checks = (deploy-rs.lib."${system}".deployChecks self.deploy.${system}) // {
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
            enable = true;
            entry = mkForce "${pkgs.nodePackages.eslint}/bin/eslint";
            files = "\\.ts$";
          };

          prettier = {
            enable = true;
            entry = mkForce "${pkgs.nodePackages.prettier}/bin/prettier --check";
            types_or = mkForce [
              "javascript"
              "json"
              "markdown"
              "yaml"
            ];
          };

          prettier-ts = {
            enable = true;
            entry = mkForce "${pkgs.nodePackages.prettier}/bin/prettier --check";
            files = "\\.ts$";
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
)
