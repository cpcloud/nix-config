let
  sources = import ./nix;
  pkgs = import sources.nixpkgs { };
in
pkgs.mkShell {
  name = "nixos-config";
  nativeBuildInputs = [
    (pkgs.callPackage sources.sops-nix { }).sops-import-keys-hook
  ];
  buildInputs = (with pkgs; [
    gnupg
    jq
    niv
    nix-linter
    nixpkgs-fmt
    sops
    ssh-to-pgp
    yj
  ]);

  sopsPGPKeyDirs = [
    "./keys/hosts"
    "./keys/users"
  ];

  SOPS_GPG_KEYSERVER = "https://keys.openpgp.org";
}
