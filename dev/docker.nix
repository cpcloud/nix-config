{ pkgs, lib, ... }:
let
  json = pkgs.formats.json { };
  enableDocker = true;
in
{
  # enable docker
  virtualisation.docker.enable = enableDocker;

  # this is needed for docker builds that contact the internet, gross
  boot.kernel.sysctl = lib.optionalAttrs enableDocker {
    "net.ipv4.ip_forward" = 1;
  };

  # allow use of the GCR mirror of docker images
  environment.etc = lib.optionalAttrs enableDocker {
    "docker/daemon.json".source = json.generate "docker_daemon.json" {
      registry-mirrors = [ "https://mirror.gcr.io" ];
    };
  };
}
