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
      in
      {
        devShell = pkgs.mkShell {
          name = "pulumi";
          buildInputs = with pkgs; [
            google-cloud-sdk
            nodejs
            pulumi-bin
            yarn
          ];

          shellHook = ''
            yarn install 1>&2
          '';

          PULUMI_SKIP_UPDATE_CHECK = "1";
        };
      }
    );
}


