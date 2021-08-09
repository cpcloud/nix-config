let
  sources = import ../nix;
  pkgs = import sources.nixpkgs { };
in
pkgs.mkShell {
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
}
