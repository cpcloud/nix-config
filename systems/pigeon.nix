{ config, ... }: {
  imports = [
    ../core

    ../dev
    ../dev/docker.nix

    ../hardware/machines/xps-7590.nix
    ../hardware/gpu/nvidia/containers
    ../hardware/gpu/nvidia/containers/docker.nix
    ../hardware/yubikey.nix

    ../hardware/tpu/coral.nix

    ../headful

    ../users/cloud
  ];

  home-manager.users.cloud = { ... }: {
    imports = [ ../users/cloud/headful/trusted.nix ];
  };

  fileSystems = {
    "/" =
      {
        device = "/dev/disk/by-uuid/befc151d-52dd-40f3-ab76-37c76c35acaa";
        fsType = "ext4";
      };
    "/boot" =
      {
        device = "/dev/disk/by-uuid/49B6-3F24";
        fsType = "vfat";
      };
  };

  swapDevices = [{ device = "/dev/disk/by-uuid/cee8fdec-ca6c-4826-9522-ea9463b77a46"; }];

  networking = {
    hostName = "pigeon";
    networkmanager.enable = true;
  };

  fonts.fontconfig.dpi = 192;

  services = {
    xserver = {
      inherit (config.fonts.fontconfig) dpi;
      videoDrivers = [ "nvidia" ];

      displayManager.lightdm.greeters.gtk = {
        cursorTheme.size = 48;
        extraConfig = "xft-dpi=${toString config.fonts.fontconfig.dpi}";
      };
    };
  };

  programs.nm-applet.enable = true;

  time.timeZone = "America/New_York";
}
