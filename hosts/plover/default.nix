{ pkgs, ... }: {
  imports = [
    ../../core

    ../../users/cloud

    ../../dev
    ../../dev/albatross-builder.nix
    ../../dev/falcon-builder.nix

    ../../hardware/machines/rpi4.nix
    ../../hardware/tpu/coral.nix
  ];

  console = {
    font = "ter-v28n";
    packages = with pkgs; [ terminus_font ];
  };

  environment.noXlibs = true;
  services.xserver.enable = false;

  networking = {
    hostName = "plover";
    interfaces = {
      wlan0.useDHCP = true;
      eth0.useDHCP = true;
    };
  };

  time.timeZone = "America/New_York";

  home-manager.users.cloud.home.packages = with pkgs; [
    libraspberrypi
    raspberrypi-eeprom
    v4l-utils
  ];
}
