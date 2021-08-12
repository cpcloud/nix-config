let
  sources = import ./nix/sources.nix;
  pkgs = import sources.nixpkgs { };
  pre-commit-hooks = import sources.pre-commit-hooks;
  lib = pkgs.lib;
in
{
  pre-commit-check = pre-commit-hooks.run {
    src = ./.;
    hooks = {
      nix-linter = {
        enable = true;
        entry = lib.mkForce "nix-linter";
        excludes = [
          "nix/sources.nix"
        ];
      };

      nixpkgs-fmt = {
        enable = true;
        entry = lib.mkForce "nixpkgs-fmt";
      };

      prettier = {
        enable = true;
        entry = lib.mkForce "prettier --check";
        types_or = lib.mkForce [ "toml" "yaml" "json" ];
      };

      eslint = {
        enable = true;
        entry = lib.mkForce "eslint --resolve-plugins-relative-to pulumi";
        files = "\\.ts$";
      };

      shellcheck = {
        enable = true;
        entry = lib.mkForce "shellcheck";
        files = "\\.sh$";
        types_or = lib.mkForce [ ];
      };

      shfmt = {
        enable = true;
        entry = lib.mkForce "shfmt -i 2 -sr -d -s -l";
        files = "\\.sh$";
      };

      stylua = {
        enable = true;
        entry = lib.mkForce "stylua --check";
        files = "\\.lua$";
      };
    };
  };
}
