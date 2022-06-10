# Personal NixOS Configuration(s)

This repository contains my personal NixOS configurations, heavily cribbed from
and inspired by [lovesegfault/nix-config](https://github.com/lovesegfault/nix-config).

- Deployment is done with [deploy-rs](https://github.com/serokell/deploy-rs).
- Secrets are managed with [sops](https://github.com/mozilla/sops) and
  [sops-nix](https://github.com/Mic92/sops-nix).

## Cloud Machine Deployment

For a given `$HOST`:

```sh
# log out of tailscale on existing machine to prevent hostname collision
sudo tailscale down
sudo tailscale logout

# deploy to the cloud
pulumi up

# get the raw instance name for the host you've just deployed
INSTANCE="$(pulumi stack output $HOST)"

# get tailscale auth-key
TS_AUTH_KEY="$(sops -d secrets/tailscale.yaml | yj -yj | jq -rcM '.[$host]' --arg host $HOST)"

# start tailscale to allow SSH without gcp, invalidate the key after 1 second
gcloud compute ssh "$INSTANCE" --tunnel-through-iap --zone=us-east4-b --command="sudo tailscale up --auth-key=$TS_AUTH_KEY" --ssh-key-expire-after=30s

# remove previous known host key from `~/.ssh/known_hosts`
# TODO: this is a manual step

# remove useless google cloud key
srm ~/.ssh/google_compute_*

# get the host pubkey
ssh "$HOST" 'nix-shell -p ssh-to-pgp --run "sudo ssh-to-pgp -i /etc/ssh/ssh_host_rsa_key"' 1> keys/hosts/$HOST.asc

# paste the output to the right place in `.sops.yaml`
# TODO: this is a manual step, how should it be automated?

# rekey
sops-rekey

# re-enable any disabled builders, e.g., falcon on weebill
```

## TODO

- The [`xps-9310` kernel
  patch](https://github.com/NixOS/nixos-hardware/blob/master/dell/xps/13-9310/default.nix#L9-L20)
  added in [`nixos-hardware`](https://github.com/NixOS/nixos-hardware) seems to
  prevent some part of systemd from starting and thus prevent deployment.
