let
  sources = import ../nix;
  pkgs = import sources.nixpkgs { };
in
pkgs.mkShell {
  name = "pulumi";
  buildInputs = (with pkgs; [
    cacert
    google-cloud-sdk
    nodejs
    pulumi-bin
  ]) ++ (with pkgs.nodePackages; [
    npm
    typescript
    eslint
  ]);

  shellHook = ''
    npm install --no-fund
  '';

  PULUMI_SKIP_UPDATE_CHECK = "1";
  SSL_CERT_FILE = "${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt";
}
