{ self, ... }:

system:

with self.nixpkgs.${system};

let
  styluaSettings = builtins.fromTOML (
    lib.replaceStrings [ "_" ] [ "-" ] (lib.readFile ../stylua.toml)
  );
  styluaSettingsArgs = lib.concatStringsSep
    " "
    (lib.mapAttrsToList (name: value: "--${name}=${toString value}") styluaSettings);
  styluaWithFormat = writeShellApplication {
    name = "stylua";
    text = ''
      ${stylua}/bin/stylua ${styluaSettingsArgs} "$@"
    '';
  };
  sops-rekey = writeShellApplication {
    name = "sops-rekey";
    runtimeInputs = [ fd sops ];
    text = ''
      fd '\.yaml' "$PWD/secrets" --exec sops updatekeys --yes
    '';
  };
  sops-rotate = writeShellApplication {
    name = "sops-rotate";
    runtimeInputs = [ fd sops ];
    text = ''
      fd '\.yaml' "$PWD/secrets" --exec sops --rotate --in-place
    '';
  };
  post-deploy = writeShellApplication {
    name = "post-deploy";
    runtimeInputs = [
      google-cloud-sdk
      jq
      pulumi-bin
      sops
      srm
      yj
    ];
    text = ''
      CLOUD_HOST="$1"

      # get the raw instance name for the host you've just deployed
      INSTANCE="$(pulumi stack output "$CLOUD_HOST")"

      # get tailscale auth-key
      TS_AUTH_KEY="$(sops -d "$PWD/secrets/tailscale.yaml" | yj -yj | jq -rcM '.[$host]' --arg host "$CLOUD_HOST")"

      # auth to tailscale
      gcloud compute ssh "$INSTANCE" --tunnel-through-iap --command="sudo tailscale up --auth-key=$TS_AUTH_KEY" --ssh-key-expire-after=30s

      # remove now-useless keys
      srm ~/.ssh/google_compute*
    '';
  };

  remove-tailscale-device = writeShellApplication {
    name = "remove-tailscale-device";
    runtimeInputs = [
      curl
      jq
      sops
      yj
    ];
    text =
      let
        api = "https://api.tailscale.com/api/v2";
      in
      ''
        DEVICE_NAME="$1"
        API_KEY="$(sops -d "$PWD/secrets/tailscale.yaml" | yj -yj | jq -rcM '.api')"
        DEVICE_ID="$(curl -sSL -X GET "${api}/tailnet/cpcloud.github/devices" -u "''${API_KEY}:" | \
          jq -rcM '.devices[] | select(.hostname == $host) | .id' --arg host "$DEVICE_NAME")"
        curl -X DELETE "${api}/device/''${DEVICE_ID}" -u "''${API_KEY}:" -v
      '';
  };
in
mkShell {
  name = "nix-config";

  nativeBuildInputs = [
    awscli2
    cachix
    deploy-rs.deploy-rs
    git
    gnupg
    google-cloud-sdk
    jq
    nix-linter
    nixos-shell
    nixpkgs-fmt
    nodejs
    post-deploy
    pre-commit
    prettierWithToml
    pulumi-bin
    remove-tailscale-device
    sops
    sops-import-keys-hook
    sops-rekey
    sops-rotate
    srm
    ssh-to-pgp
    styluaWithFormat
    yarn
    yj
  ] ++ lib.optionals (!stdenv.isAarch64) [ ssm-session-manager-plugin ];

  sopsPGPKeyDirs = [
    ../keys/hosts
    ../keys/users
  ];

  SOPS_GPG_KEYSERVER = "https://keys.openpgp.org";

  shellHook = ''
    ${self.checks.${system}.pre-commit-check.shellHook}
    yarn install 1>&2
  '';

  PULUMI_SKIP_UPDATE_CHECK = "1";
}
