{ config, ... }: {
  imports = [
    ../../core

    ../../dev
    ../../dev/docker.nix
    ../../dev/falcon-builder.nix

    ../../hardware/machines/xps-9310.nix
    ../../hardware/yubikey.nix

    ../../headful

    ../../users/cloud
  ];

  home-manager.users.cloud = { ... }: {
    imports = [ ((import ../../users/cloud/trusted) config.networking.hostName) ];
    programs.alacritty.settings.font.size = 5.5;
  };

  boot = {
    binfmt.emulatedSystems = [ "aarch64-linux" ];
    tmpOnTmpfsSize = "95%";
  };

  fileSystems = {
    "/" = {
      device = "/dev/disk/by-uuid/f8190e62-431f-4500-b728-4b8a8fff4895";
      fsType = "ext4";
    };

    "/boot" = {
      device = "/dev/disk/by-uuid/1A73-97F8";
      fsType = "vfat";
    };
  };

  swapDevices = [
    { device = "/dev/disk/by-uuid/89773b94-695e-4cd7-96f2-33ccec50926d"; }
  ];

  networking = {
    hostName = "weebill";
    networkmanager.enable = true;
  };

  programs.nm-applet.enable = true;

  time.timeZone = null;
}
