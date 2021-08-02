{ pkgs, lib, ... }: rec {
  imports = [
    # FIXME: this is broken upstream
    # "${(import ../../nix).nixos-hardware}/dell/xps/13-9310"
    "${(import ../../nix).nixos-hardware}/common/cpu/intel"
    "${(import ../../nix).nixos-hardware}/common/pc/laptop"
    ../audio.nix
    ../bluetooth.nix
    ../efi.nix
    ../hardware.nix
  ];

  boot = {
    initrd.availableKernelModules = [
      "xhci_pci"
      "thunderbolt"
      "nvme"
      "usb_storage"
      "sd_mod"
      "rtsx_pci_sdmmc"
    ];
    blacklistedKernelModules = [ "psmouse" ];
    kernelModules = [ "kvm-intel" "amdgpu" ];
    kernelPackages = pkgs.linuxPackages_xanmod_lto_tigerlake;
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
