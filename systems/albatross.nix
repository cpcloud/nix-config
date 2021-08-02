{ config, pkgs, ... }: {
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
    ../headful/trusted.nix

    ../users/cloud
  ];

  sops.secrets.albatross_github_runner = {
    sopsFile = ../secrets/albatross-github-runner.yaml;
  };

  services.github-runner = {
    enable = true;
    replace = true;
    url = "https://github.com/cpcloud/nixos-config";
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
    networkmanager.enable = true;
  };

  services.xserver.videoDrivers = [ "nvidia" ];

  programs.nm-applet.enable = true;

  time.timeZone = "America/New_York";
}
