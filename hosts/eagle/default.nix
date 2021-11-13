{ config, ... }: {
  imports = [
    ../../core

    ../../dev
    ../../dev/docker.nix

    ../../hardware/machines/aws/aws.nix

    ../../users/cloud
  ];

  home-manager.users.cloud = { ... }: {
    imports = [ ((import ../../users/cloud/trusted) config.networking.hostName) ];
  };

  networking.hostName = "eagle";

  time.timeZone = "America/New_York";
}
