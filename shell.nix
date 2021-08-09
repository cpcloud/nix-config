let
  sources = import ./nix;
  pkgs = import sources.nixpkgs { };
  sops-nix = pkgs.callPackage sources.sops-nix { };
in
pkgs.mkShell {
  name = "nix-config";
  nativeBuildInputs = [ sops-nix.sops-import-keys-hook ];
  buildInputs = with pkgs; [
    cryptsetup
    gnupg
    jq
    niv
    nix-linter
    nixpkgs-fmt
    sops
    srm
    ssh-to-pgp
    yj
  ];

  sopsPGPKeyDirs = [
    "./keys/hosts"
    "./keys/users"
  ];

  SOPS_GPG_KEYSERVER = "https://keys.openpgp.org";
}
