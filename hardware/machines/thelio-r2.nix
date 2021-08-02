{ pkgs, lib, ... }:
let
  sources = import ../../nix;
in
{
  imports = [
    "${sources.nixos-hardware}/common/cpu/amd"
    "${sources.nixos-hardware}/common/pc/ssd"
    ../audio.nix
    ../bluetooth.nix
    ../efi.nix
    ../gpu/nvidia/basic.nix
    ../hardware.nix
  ];

  boot = {
    initrd.availableKernelModules = [ "nvme" "xhci_pci" "ahci" "usbhid" ];
    kernelModules = [ "kvm-amd" ];
  };

  powerManagement.cpuFreqGovernor = lib.mkDefault "performance";
  console.font = "${pkgs.terminus_font}/share/consolefonts/ter-u28n.psf.gz";

  services = {
    fstrim.enable = true;
    fwupd.enable = true;
  };

  nix = {
    nrBuildUsers = 32;
    maxJobs = 32;
    buildCores = 32;
  };
}
