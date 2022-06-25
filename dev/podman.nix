{ config, lib, pkgs, ... }: {
  virtualisation.podman.enable = true;
  virtualisation.podman.dockerSocket.enable = !config.virtualisation.docker.enable;
  virtualisation.podman.defaultNetwork.dnsname.enable = !config.virtualisation.docker.enable;
  environment.systemPackages = lib.optionals
    config.virtualisation.podman.dockerSocket.enable
    [ pkgs.docker-client ];
}
