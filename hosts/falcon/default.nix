{ config, lib, ... }: {
  imports = [
    ../../core

    ../../dev
    ../../dev/docker.nix

    ../../hardware/machines/gce/gce.nix

    ../../users/cloud
  ];

  networking.dhcpcd = lib.optionalAttrs config.virtualisation.docker.enable {
    denyInterfaces = [ "veth*" ];
  };

  boot.binfmt.emulatedSystems = [ "aarch64-linux" ];

  home-manager.users.cloud = {
    imports = [ ((import ../../users/cloud/trusted) config.networking.hostName) ];
  };

  networking.hostName = "falcon";

  time.timeZone = "America/New_York";
}
