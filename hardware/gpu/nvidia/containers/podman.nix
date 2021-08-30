{ config, ... }: {
  virtualisation.podman.enableNvidia = config.virtualisation.podman.enable;
}
