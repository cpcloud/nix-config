{ modulesPath, lib, ... }: {
  imports = [
    # Make sure to have this in all your GCE configurations to enable
    # generating a machine image
    "${toString modulesPath}/virtualisation/google-compute-image.nix"
    "${(import ../../../nix).nixos-hardware}/common/cpu/intel"
    ../../hardware.nix
  ];

  virtualisation.googleComputeImage.diskSize = 10 * 1024;

  networking = {
    useNetworkd = lib.mkForce false;
    interfaces.eth0.useDHCP = true;
  };

  systemd.services.fetch-instance-ssh-keys.enable = lib.mkForce false;

  powerManagement.cpuFreqGovernor = lib.mkDefault "performance";

  nixpkgs = {
    localSystem.system = "x86_64-linux";

    overlays = [
      (_: super: {
        google-cloud-sdk = super.google-cloud-sdk.override {
          with-gce = true;
        };
      })
    ];
  };

  services = {
    fstrim.enable = true;
    fwupd.enable = true;
  };
}
