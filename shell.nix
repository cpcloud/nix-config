let
  sources = import ./nix;
  pkgs = import sources.nixpkgs {
    overlays = [
      (import ./overlays/write-sane-shell-script-bin.nix)
    ];
  };
  sops-nix = pkgs.callPackage sources.sops-nix { };
  get-commit = pkgs.writeSaneShellScriptBin {
    name = "get-commit";
    buildInputs = with pkgs; [ jq ];
    src = ''
      jq --exit-status --arg dep "$1" -rcM \
      '.[$dep].rev // error("no niv-managed \"\($dep)\" dependency")' < ${./nix/sources.json}
    '';
  };
in
pkgs.mkShell {
  name = "nix-config";
  nativeBuildInputs = [ sops-nix.sops-import-keys-hook ];
  buildInputs = with pkgs; [
    cryptsetup
    get-commit
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
