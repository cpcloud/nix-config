{ ... }: {
  imports = [
    ../core

    ../dev
    ../dev/docker.nix
    ../dev/albatross-builder.nix

    ../hardware/machines/asus-zenbook.nix

    ../hardware/yubikey.nix

    ../headful
    ../headful/trusted.nix

    ../users/cloud
  ];

  fileSystems = {
    "/" =
      {
        device = "/dev/disk/by-uuid/e020a3de-1631-4a54-aef7-8a4480b6ef05";
        fsType = "ext4";
      };
    "/boot" =
      {
        device = "/dev/disk/by-uuid/B788-288A";
        fsType = "vfat";
      };
  };

  swapDevices = [{ device = "/dev/disk/by-uuid/7d0b7a87-e6e7-47e5-b6c7-bbee0a647ad0"; }];

  networking = {
    hostName = "bluejay";
    networkmanager.enable = true;
  };

  programs.nm-applet.enable = true;

  time.timeZone = "America/New_York";
}
