{ config, ... }: {
  imports = [
    ../core

    ../dev
    ../dev/docker.nix
    ../dev/albatross-builder.nix

    ../hardware/machines/xps-9310.nix
    ../hardware/yubikey.nix
    ../hardware/gpu/amd

    ../headful

    ../users/cloud
  ];

  home-manager.users.cloud = { ... }: {
    imports = [ ((import ../users/cloud/trusted) config.networking.hostName) ];
    programs.alacritty.settings.font.size = 5;
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
    useDHCP = false;
    useNetworkd = true;
    wireless.iwd.enable = true;
  };

  systemd.network.networks = {
    lan = {
      DHCP = "yes";
      matchConfig.MACAddress = "38:14:28:bb:61:fe";
    };
    wifi = {
      DHCP = "yes";
      matchConfig.MACAddress = "4c:79:6e:d5:1f:88";
    };
  };

  services.resolved.enable = true;

  time.timeZone = "America/New_York";
}
