{ ... }: {
  imports = [
    ../core

    ../dev
    ../dev/docker.nix

    ../hardware/machines/xps-9310.nix
    ../hardware/yubikey.nix
    ../hardware/gpu/amd

    ../headful

    ../users/cloud
    ../users/cloud/headful/trusted.nix
    ../users/cloud/trusted.nix
  ];

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
      matchConfig.Name = "enp60s0u2u4";
    };
    wifi = {
      DHCP = "yes";
      matchConfig.Name = "wlan0";
    };
  };

  services.resolved.enable = true;

  time.timeZone = "America/New_York";
}
