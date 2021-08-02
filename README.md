# Personal NixOS Configuration(s)

This repository contains my personal NixOS configurations, heavily inspired by
[lovesegfault/nix-config](https://github.com/lovesegfault/nix-config).

- Deployment is done with [nixus](https://github.com/Infinisil/nixus).
- Secrets are managed with [sops](https://github.com/mozilla/sops) and
  [sops-nix](https://github.com/Mic92/sops-nix).

## TODO

1. The [`xps-9310` kernel
   patch](https://github.com/NixOS/nixos-hardware/blob/master/dell/xps/13-9310/default.nix#L9-L20)
   added in [`nixos-hardware`](https://github.com/NixOS/nixos-hardware) seems
   to prevent some part of systemd from starting and thus prevent deployment.
