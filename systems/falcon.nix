{ ... }: {
  imports = [
    ../core

    ../dev
    ../dev/docker.nix

    ../hardware/machines/gce/gce.nix

    ../users/cloud
  ];

  home-manager.users.cloud = { ... }: {
    imports = [ ../users/cloud/trusted/curses.nix ];
  };

  networking.hostName = "falcon";

  time.timeZone = "America/New_York";
}
