{ config, ... }: {
  virtualisation.docker.enableNvidia = config.virtualisation.docker.enable;
}
