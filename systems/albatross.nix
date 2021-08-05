{ config, pkgs, lib, ... }: {
  imports = [
    ../core

    ../dev
    ../dev/docker.nix
    ../dev/podman.nix

    ../hardware/machines/thelio-r2.nix

    ../hardware/gpu/nvidia/containers
    ../hardware/gpu/nvidia/containers/docker.nix
    ../hardware/gpu/nvidia/containers/podman.nix

    ../hardware/yubikey.nix

    ../hardware/tpu/coral.nix

    ../headful

    ../users/cloud
  ];

  home-manager.users.cloud = { ... }: {
    imports = [ ../users/cloud/trusted/gnome.nix ];
  };

  sops.secrets.albatross_github_runner = {
    sopsFile = ../secrets/albatross-github-runner.yaml;
  };

  services.github-runner = {
    enable = true;
    url = "https://github.com/cpcloud/nix-config";
    tokenFile = config.sops.secrets.albatross_github_runner.path;
    extraPackages = [ pkgs.cachix ];
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
