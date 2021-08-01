let
  sources = import ./nix;
  pkgs = import sources.nixpkgs { };
in
pkgs.mkShell {
  name = "nixos-config";
  nativeBuildInputs = [
    (pkgs.callPackage sources.sops-nix {}).sops-import-keys-hook
  ];
  buildInputs = (with pkgs; [
    cacert
    gnupg
    google-cloud-sdk
    jq
    niv
    nix
    nix-linter
    nixpkgs-fmt
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

  sopsPGPKeyDirs = [
    "./keys/hosts"
    "./keys/users"
  ];

  PULUMI_SKIP_UPDATE_CHECK = "1";
  SSL_CERT_FILE = "${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt";
}
