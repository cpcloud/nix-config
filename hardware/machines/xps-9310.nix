{ pkgs, lib, ... }: rec {
  imports = [
    "${(import ../../nix).nixos-hardware}/dell/xps/13-9310"
    ../audio.nix
    ../bluetooth.nix
    ../efi.nix
    ../hardware.nix
  ];

  boot = {
    initrd.availableKernelModules = [ "xhci_pci" "ahci" "nvme" "usbhid" "rtsx_pci_sdmmc" ];
    kernelModules = [ "kvm-intel" ];
  };

  powerManagement.cpuFreqGovernor = lib.mkDefault "powersave";
  console.font = "${pkgs.terminus_font}/share/consolefonts/ter-u28n.psf.gz";

  services = {
    fwupd.enable = true;
    fstrim.enable = true;
    hardware.bolt.enable = true;
  };

  nix = {
    nrBuildUsers = 8;
    maxJobs = 8;
    buildCores = 8;
  };
}
