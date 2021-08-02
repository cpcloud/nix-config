{ ... }: {
  imports = [
    ../core

    ../dev
    ../dev/docker.nix

    ../hardware/machines/xps-9310.nix
    ../hardware/yubikey.nix

    ../headful
    ../headful/trusted.nix

    ../users/cloud
  ];

  fileSystems = {
    "/" =
      {
        device = "/dev/disk/by-label/nixos";
        fsType = "ext4";
      };
    "/boot" =
      {
        device = "/dev/disk/by-label/BOOT";
        fsType = "vfat";
      };
  };

  swapDevices = [{ device = "/dev/disk/by-label/swap"; }];

  networking = {
    hostName = "weebill";
    networkmanager.enable = true;
  };

  programs.nm-applet.enable = true;

  time.timeZone = "America/New_York";
}
