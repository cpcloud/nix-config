{ ... }: {
  imports = [
    ../core

    ../dev
    ../dev/docker.nix

    ../hardware/machines/gce/gce.nix

    ../users/cloud
  ];

  networking.hostName = "falcon";

  time.timeZone = "America/New_York";
}
