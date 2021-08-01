{ pkgs, lib, ... }: rec {
  imports = [
    "${(import ../../nix).nixos-hardware}/dell/xps/15-7590"
    ../audio.nix
    ../bluetooth.nix
    ../cpu/intel.nix
    ../efi.nix
    ../gpu/nvidia/prime.nix
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
    nrBuildUsers = 12;
    maxJobs = 12;
    buildCores = 12;
  };
}
