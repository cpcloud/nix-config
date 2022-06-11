{ config, lib, ... }: {
  imports = [
    ../../core

    ../../dev
    ../../dev/docker.nix

    ../../hardware/machines/gce/gce.nix

    ../../users/cloud
  ];

  virtualisation.docker.daemon.settings =
    lib.optionalAttrs config.virtualisation.docker.enable {
      default-address-pools = [
        {
          base = "172.31.0.0/16";
          size = 24;
        }
      ];
    };

  home-manager.users.cloud = { ... }: {
    imports = [ ((import ../../users/cloud/trusted) config.networking.hostName) ];
  };

  networking.hostName = "falcon";

  time.timeZone = "America/New_York";
}
