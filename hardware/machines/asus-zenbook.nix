{ pkgs, lib, ... }: rec {
  imports = [
    ../audio.nix
    ../bluetooth.nix
    "${(import ../../nix).nixos-hardware}/common/cpu/intel"
    ../efi.nix
    ../hardware.nix
  ];

  boot = {
    initrd.availableKernelModules = [ "xhci_pci" "nvme" "usb_storage" "sd_mod" ];
    kernelModules = [ "kvm-intel" ];
  };

  powerManagement.cpuFreqGovernor = lib.mkDefault "powersave";
  console.font = "${pkgs.terminus_font}/share/consolefonts/ter-u28n.psf.gz";

  services = {
    fwupd.enable = true;
    fstrim.enable = true;
  };

  nix = {
    nrBuildUsers = 4;
    maxJobs = 4;
    buildCores = 4;
  };
}
