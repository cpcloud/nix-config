{ pkgs, ... }: {
  imports = [
    ../../core

    ../../dev
    ../../dev/albatross-builder.nix
    ../../dev/falcon-builder.nix

    ../../hardware/machines/rpi4.nix
    ../../hardware/tpu/coral.nix
    ../../hardware/yubikey.nix

    ../../users/cloud
  ];

  console = {
    font = "ter-v28n";
    packages = [ pkgs.terminus_font ];
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
  ];
}
