{ mkShell
, lib
, awscli2
, cachix
, deploy-rs
, findutils
, git
, glow
, gnupg
, google-cloud-sdk
, jq
, nix-linter
, nixos-shell
, nixpkgs-fmt
, nodejs
, pre-commit
, pre-commit-check
, prettierWithToml
, pulumi-bin
, sops
, sops-import-keys-hook
, srm
, ssh-to-pgp
, ssm-session-manager-plugin
, stylua
, writeShellApplication
, yarn
, yj
}:
let
  styluaSettings = builtins.fromTOML (
    lib.replaceStrings [ "_" ] [ "-" ] (lib.readFile ../stylua.toml)
  );
  styluaSettingsArgs = lib.concatStringsSep
    " "
    (lib.mapAttrsToList (name: value: "--${name}=${toString value}") styluaSettings);
  styluaWithFormat = writeShellApplication {
    name = "stylua";
    runtimeInputs = [ ];
    text = ''
      ${stylua}/bin/stylua ${styluaSettingsArgs} "$@"
    '';
  };
  sops-rekey = writeShellApplication {
    name = "sops-rekey";
    runtimeInputs = [ findutils sops ];
    text = ''
      find secrets -name '*.yaml' -exec sops updatekeys -y {} +
    '';
  };
in
mkShell {
  name = "nix-config";

  nativeBuildInputs = [
    awscli2
    cachix
    deploy-rs
    git
    glow
    gnupg
    google-cloud-sdk
    jq
    nix-linter
    nixos-shell
    nixpkgs-fmt
    nodejs
    pulumi-bin
    pre-commit
    prettierWithToml
    sops
    sops-import-keys-hook
    srm
    ssh-to-pgp
    ssm-session-manager-plugin
    styluaWithFormat
    yarn
    yj
    sops-rekey
  ];

  sopsPGPKeyDirs = [
    "${../keys/hosts}"
    "${../keys/users}"
  ];

  SOPS_GPG_KEYSERVER = "https://keys.openpgp.org";

  shellHook = ''
    ${pre-commit-check.shellHook}
    yarn install 1>&2
  '';
  PULUMI_SKIP_UPDATE_CHECK = "1";
}
