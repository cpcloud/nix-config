{ config, lib, ... }: {
  imports = [
    ../../core

    ../../dev
    ../../dev/docker.nix

    ../../hardware/machines/gce/gce.nix
    ../../hardware/aarch64-linux-emulation.nix

    ../../users/cloud
  ];

  networking.dhcpcd = lib.optionalAttrs config.virtualisation.docker.enable {
    denyInterfaces = [ "veth*" ];
  };

  home-manager.users.cloud = {
    imports = [ ((import ../../users/cloud/trusted) config.networking.hostName) ];
  };

  networking.hostName = "falcon";

  time.timeZone = "America/New_York";
}
