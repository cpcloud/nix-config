{ config, lib, ... }: {
  imports = [
    ../../core

    ../../dev
    ../../dev/docker.nix
    ../../dev/albatross-builder.nix

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

  nix = {
    nrBuildUsers = 32;
    settings = {
      max-jobs = 32;
      cores = 32;
    };
  };

  time.timeZone = "America/New_York";
}
