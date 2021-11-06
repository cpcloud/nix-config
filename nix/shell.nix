{ mkShell
, lib
, cachix
, git
, gnupg
, jq
, google-cloud-sdk
, nodejs
, pulumi-bin
, yarn
, nix-linter
, shellcheck
, nixpkgs-fmt
, shfmt
, pre-commit
, stylua
, sops
, srm
, yj
, sops-import-keys-hook
, deploy-rs
, pre-commit-check
, ssh-to-pgp
, writeShellScriptBin
, prettierWithToml
}:
let
  styluaSettings = builtins.fromTOML (
    lib.replaceStrings [ "_" ] [ "-" ] (lib.readFile ../stylua.toml)
  );
  styluaSettingsArgs = lib.concatStringsSep
    " "
    (lib.mapAttrsToList (name: value: "--${name}=${toString value}") styluaSettings);
  styluaWithFormat = writeShellScriptBin "stylua" ''
    set -euo pipefail

    ${stylua}/bin/stylua ${styluaSettingsArgs} "$@"
  '';
in
mkShell {
  name = "nix-config";

  nativeBuildInputs = [
    cachix
    deploy-rs
    git
    gnupg
    google-cloud-sdk
    jq
    nix-linter
    nixpkgs-fmt
    nodejs
    pre-commit
    prettierWithToml
    pulumi-bin
    shellcheck
    shfmt
    sops
    sops-import-keys-hook
    srm
    ssh-to-pgp
    styluaWithFormat
    yarn
    yj
  ];

  sopsPGPKeyDirs = [
    "./keys/hosts"
    "./keys/users"
  ];

  SOPS_GPG_KEYSERVER = "https://keys.openpgp.org";

  shellHook = ''
    ${pre-commit-check.shellHook}
    yarn install 1>&2
  '';

  PULUMI_SKIP_UPDATE_CHECK = "1";
}
