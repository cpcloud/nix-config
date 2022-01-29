{ pkgs
, lib
, ...
}: rec {
  imports = [
    # FIXME: this is broken upstream
    # "${(import ../../nix).nixos-hardware}/dell/xps/13-9310"
    ../audio.nix
    ../bluetooth.nix
    ../efi.nix
    ../hardware.nix
    ../brightness.nix
  ];

  boot = {
    extraModprobeConfig = "options kvm_intel nested=1";
    initrd.availableKernelModules = [
      "xhci_pci"
      "thunderbolt"
      "nvme"
      "usb_storage"
      "sd_mod"
      "rtsx_pci_sdmmc"
    ];
    blacklistedKernelModules = [ "psmouse" ];
    kernelModules = [ "kvm-intel" "kvm_intel" ];
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
    settings = {
      max-jobs = 8;
      cores = 8;
    };
  };
}
