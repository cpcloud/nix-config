{ modulesPath, lib, ... }: {
  imports = [
    # Make sure to have this in all your GCE configurations to enable
    # generating a machine image
    "${toString modulesPath}/virtualisation/google-compute-image.nix"
    ../../cpu/intel.nix
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
      (self: super: {
        # XXX: boto is used by google-compute-engine, and boto is not compatible
        # with Python > 3.8, so we downgrade these two libraries to allow
        # the system to work
        google-compute-engine = super.python38Packages.google-compute-engine;
        google-cloud-sdk = super.google-cloud-sdk.override {
          python = self.python38;
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
