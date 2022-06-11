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
      find secrets -name '*.yaml' -exec sops updatekeys -y {} \;
    '';
  };
  sops-rotate = writeShellApplication {
    name = "sops-rotate";
    runtimeInputs = [ findutils sops ];
    text = ''
      find secrets -name '*.yaml' -exec sops -r -i {} \;
    '';
  };
  post-deploy = writeShellApplication {
    name = "post-deploy";
    runtimeInputs = [
      google-cloud-sdk
      jq
      pulumi-bin
      sops
      yj
    ];
    text = ''
      CLOUD_HOST="$1"

      # get the raw instance name for the host you've just deployed
      INSTANCE="$(pulumi stack output "$CLOUD_HOST")"

      # get tailscale auth-key
      TS_AUTH_KEY="$(sops -d "${../secrets/tailscale.yaml}" | yj -yj | jq -rcM '.[$host]' --arg host "$CLOUD_HOST")"

      # auth to tailscale
      gcloud compute ssh "$INSTANCE" --tunnel-through-iap --command="sudo tailscale up --auth-key=$TS_AUTH_KEY" --ssh-key-expire-after=30s
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
    post-deploy
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
    sops-rotate
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
