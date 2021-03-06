{ config, lib, pkgs, ... }: {
  imports = [
    ../../core

    ../../dev
    ../../dev/docker.nix
    ../../dev/podman.nix

    ../../hardware/machines/thelio-r2.nix

    ../../hardware/gpu/nvidia/containers
    ../../hardware/gpu/nvidia/containers/docker.nix
    ../../hardware/gpu/nvidia/containers/podman.nix

    ../../hardware/yubikey.nix
    ../../hardware/tpu/coral.nix
    ../../hardware/aarch64-linux-emulation.nix

    ../../headful

    ../../users/cloud
  ];

  # gaming
  programs.steam.enable = true;
  # xbox controller driver
  environment.systemPackages = [ pkgs.xboxdrv ];

  home-manager.users.cloud = {
    imports = [ ((import ../../users/cloud/trusted) config.networking.hostName) ];
  };

  fileSystems = {
    "/" = {
      device = "/dev/disk/by-uuid/5a68c5b9-a66b-4efd-9fc9-b1a307c15eff";
      fsType = "ext4";
    };

    "/boot" = {
      device = "/dev/disk/by-uuid/482D-668E";
      fsType = "vfat";
    };

    "/data" = {
      device = "/dev/disk/by-uuid/1f2a9a9d-13fc-40b3-a5fe-6e3a3d000b7f";
      fsType = "ext4";
    };
  };

  swapDevices = [
    { device = "/dev/disk/by-uuid/6628cf4b-0c43-4a26-bea4-4c611246f937"; }
  ];

  networking = {
    hostName = "albatross";
    useDHCP = false;
    useNetworkd = true;
  };

  systemd.network.networks = {
    lan = {
      DHCP = "yes";
      matchConfig.MACAddress = "18:c0:4d:00:0f:1b";
    };
  } // lib.optionalAttrs config.networking.wireless.iwd.enable {
    wifi = {
      DHCP = "yes";
      matchConfig.MACAddress = "08:d2:3e:a0:7f:a8";
    };
  };

  services.resolved.enable = true;

  services.xserver.videoDrivers = [ "nvidia" ];

  time.timeZone = "America/New_York";
}
