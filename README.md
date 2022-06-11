# Personal NixOS Configuration(s)

This repository contains my personal NixOS configurations, heavily cribbed from
and inspired by [lovesegfault/nix-config](https://github.com/lovesegfault/nix-config).

- Deployment is done with [deploy-rs](https://github.com/serokell/deploy-rs).
- Secrets are managed with [sops](https://github.com/mozilla/sops) and
  [sops-nix](https://github.com/Mic92/sops-nix).

## Cloud Machine Deployment

For a given `$CLOUD_HOST`:

```sh
# disable remote builders on machines that use $CLOUD_HOST, e.g., weebill uses falcon
# TODO: automate

# on the remote machine, log out of tailscale on existing machine to prevent
# hostname collision
sudo tailscale logout

# deploy to the cloud
pulumi up

# get the raw instance name for the host you've just deployed
INSTANCE="$(pulumi stack output $CLOUD_HOST)"

# get tailscale auth-key
TS_AUTH_KEY="$(sops -d secrets/tailscale.yaml | yj -yj | jq -rcM '.[$host]' --arg host "$CLOUD_HOST")"

# auth to tailscale, invalidate the Google ssh key after 30 seconds
gcloud compute ssh "$INSTANCE" --tunnel-through-iap --command="sudo tailscale up --auth-key=$TS_AUTH_KEY" --ssh-key-expire-after=30s

# remove previous known host key from `~/.ssh/known_hosts`
# TODO: automate

# remove unnecessary google cloud key and known_hosts file
srm ~/.ssh/google_compute_*

# get the host pubkey
ssh "$CLOUD_HOST" 'nix-shell -p ssh-to-pgp --run "sudo ssh-to-pgp -i /etc/ssh/ssh_host_rsa_key"' 1> "keys/hosts/$CLOUD_HOST.asc"

# add the stderr output from the previous command to the key list in .sops.yaml
# TODO: automate

# rekey based on new pubkeys
sops-rekey

# re-enable any disabled builders, e.g., falcon on weebill
# TODO: automate
```

## TODO

- The [`xps-9310` kernel
  patch](https://github.com/NixOS/nixos-hardware/blob/master/dell/xps/13-9310/default.nix#L9-L20)
  added in [`nixos-hardware`](https://github.com/NixOS/nixos-hardware) seems to
  prevent some part of systemd from starting and thus prevent deployment.
