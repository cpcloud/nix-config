{ lib, config, ... }: {
  # enable docker
  virtualisation.docker.enable = true;

  # this is needed for docker builds that contact the internet, gross
  boot.kernel.sysctl = lib.optionalAttrs config.virtualisation.docker.enable {
    "net.ipv4.ip_forward" = 1;
  };
}
