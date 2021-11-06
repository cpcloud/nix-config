{
  description = "Pulumi provisioning code";

  inputs = {
    flake-utils.url = "github:numtide/flake-utils";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable-small";
    pre-commit-hooks = {
      url = "github:cachix/pre-commit-hooks.nix";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-utils.follows = "flake-utils";
    };
  };

  outputs = { self, nixpkgs, flake-utils, pre-commit-hooks }:
    flake-utils.lib.eachSystem [ "x86_64-linux" ] (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        inherit (pkgs.lib) mkForce;
      in
      {
        checks = {
          pre-commit-check = pre-commit-hooks.lib.${system}.run {
            src = ./.;
            tools = pkgs;
            hooks = {
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
            };
          };
        };

        devShell = pkgs.mkShell {
          name = "pulumi";
          buildInputs = with pkgs; [
            google-cloud-sdk
            nodejs
            pulumi-bin
            yarn
          ];

          shellHook = ''
            ${self.checks.${system}.pre-commit-check.shellHook}
            yarn install 1>&2
          '';

          PULUMI_SKIP_UPDATE_CHECK = "1";
        };
      }
    );
}
