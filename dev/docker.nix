{ pkgs, ... }:
let
  json = pkgs.formats.json { };
in
{
  # enable docker
  virtualisation.docker.enable = true;

  # this is needed for docker builds that contact the internet, gross
  boot.kernel.sysctl."net.ipv4.ip_forward" = 1;

  # allow use of the GCR mirror of docker images
  environment.etc."docker/daemon.json".source = json.generate "docker_daemon.json" {
    registry-mirrors = [ "https://mirror.gcr.io" ];
  };
}
