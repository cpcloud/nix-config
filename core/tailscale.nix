{ config, lib, ... }:
{
  imports = [ ./tailscale-up.nix ];

  sops.secrets.tailscale = {
    sopsFile = ../secrets/tailscale.yaml;
    key = config.networking.hostName;
  };

  systemd.services.tailscaled.after = [ "network-online.target" ]
    ++ lib.optionals config.services.resolved.enable [ "systemd-resolved.service" ];

  services = {
    tailscale.enable = true;
    tailscale-up = {
      inherit (config.services.tailscale) enable;
      authKeyFile = config.sops.secrets.tailscale.path;
    };
    fail2ban.enable = config.networking.firewall.enable;
  };

  networking.firewall = lib.optionalAttrs config.services.tailscale.enable {
    trustedInterfaces = [ "tailscale0" ];
    allowedUDPPorts = [ config.services.tailscale.port ];
    checkReversePath = "loose";
  };
}
