{ pkgs
, lib
, ...
}:
{
  imports = [
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
    settings = {
      max-jobs = 32;
      cores = 32;
    };
  };
}
