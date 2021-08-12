let
  sources = import ./nix;
  pkgs = import sources.nixpkgs { };
  sops-nix = pkgs.callPackage sources.sops-nix { };
in
pkgs.mkShell {
  name = "nix-config";
  nativeBuildInputs = [ sops-nix.sops-import-keys-hook ];
  buildInputs = (with pkgs; [
    cryptsetup
    git
    gnupg
    jq
    niv
    nix-linter
    nixpkgs-fmt
    shellcheck
    shfmt
    sops
    srm
    ssh-to-pgp
    yj
  ]) ++ (with pkgs.nodePackages; [ eslint prettier ]);

  shellHook = ''
    ${(import ./pre-commit.nix).pre-commit-check.shellHook}
  '';

  sopsPGPKeyDirs = [
    "./keys/hosts"
    "./keys/users"
  ];

  SOPS_GPG_KEYSERVER = "https://keys.openpgp.org";
}
