{ config, ... }: {
  imports = [
    ../core

    ../dev
    ../dev/docker.nix

    ../hardware/machines/gce/gce.nix

    ../users/cloud
  ];

  home-manager.users.cloud = { ... }: {
    imports = [ ((import ../users/cloud/trusted) config.networking.hostName) ];
  };

  networking.hostName = "falcon";

  time.timeZone = "America/New_York";
}
