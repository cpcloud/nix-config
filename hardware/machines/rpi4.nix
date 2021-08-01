{ pkgs, lib, ... }: {
  imports = [
    "${(import ../../nix).nixos-hardware}/raspberry-pi/4"
    ../hardware.nix
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
    };
  };

  nix = {
    nrBuildUsers = 4;
    maxJobs = 4;
    buildCores = 4;

    autoOptimiseStore = true;

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
        gb = kb * mb;
      in
      ''
        min-free = ${toString (100 * mb)}
        max-free = ${toString gb}
      '';
  };

  hardware.raspberry-pi."4".fkms-3d.enable = true;

  powerManagement.cpuFreqGovernor = lib.mkDefault "performance";
}
