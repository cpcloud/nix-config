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

  fileSystems."/" = {
    device = "/dev/disk/by-uuid/6540d52c-7864-4650-913c-0d1957a20d2f";
    fsType = "ext4";
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/56C3-F8EA";
    fsType = "vfat";
  };

  swapDevices = [
    { device = "/dev/disk/by-uuid/9cad798a-ad75-420c-8284-2dcb8573526a"; }
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

  time.timeZone = "America/New_York";
}
