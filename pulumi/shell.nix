let
  sources = import ../nix;
  pkgs = import sources.nixpkgs { };
in
pkgs.mkShell {
  name = "pulumi";
  buildInputs = (with pkgs; [
    cacert
    google-cloud-sdk
    nix
    nodejs
    pulumi-bin
    sops
    ssh-to-pgp
    yj
  ]) ++ (with pkgs.nodePackages; [
    npm
    typescript
    eslint
  ]);

  shellHook = ''
    cd pulumi && npm install --no-fund
  '';

  PULUMI_SKIP_UPDATE_CHECK = "1";
  SSL_CERT_FILE = "${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt";
}
