{ pkgs, ... }:
let
  hardwareUrl = "https://github.com/NixOS/nixos-hardware/archive/684ae160a6e76590eafa3fca8061b6ad57bcc9ad.tar.gz";
in
{
  imports = [
    "${fetchTarball hardwareUrl}/raspberry-pi/4"
  ];

  nixpkgs.localSystem.system = "aarch64-linux";

  boot = {
    kernelPackages = pkgs.linuxPackages_rpi4;

    tmpOnTmpfs = true;
    initrd.availableKernelModules = [ "usbhid" "usb_storage" "vc4" ];

    loader = {
      raspberryPi = {
        enable = true;
        version = 4;
      };
      grub.enable = false;
      generic-extlinux-compatible.enable = true;
    };
  };

  console.keyMap = "us";

  fileSystems = {
    "/" = {
      device = "/dev/disk/by-label/NIXOS";
      fsType = "ext4";
      options = [ "noatime" ];
    };
  };

  networking = {
    hostName = "plover";
    networkmanager.enable = true;
  };

  time.timeZone = "America/New_York";

  environment.systemPackages = with pkgs; [
    neovim
    libraspberrypi
    raspberrypi-eeprom
    gitAndTools.git
    gitAndTools.gh
  ];

  services.openssh.enable = true;

  users = {
    users.cloud = {
      isNormalUser = true;
      createHome = true;
      extraGroups = [ "wheel" ];
    };
  };

  nix = {
    settings = {
      trusted-users = [ "@wheel" ];
      auto-optimise-store = true;
    };
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 30d";
    };
    # Free up to 1GiB whenever there is less than 100MiB left.
    extraOptions =
      let
        kb = 1024;
        mb = kb * kb;
      in
      ''
        min-free = ${toString (100 * mb)}
        max-free = ${toString (1024 * mb)}
      '';
  };

  security.sudo = {
    enable = true;
    wheelNeedsPassword = false;
  };

  hardware.raspberry-pi."4".fkms-3d.enable = true;

  system.stateVersion = "21.11";
}
