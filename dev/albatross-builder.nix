{ config, ... }: {
  sops.secrets.albatross_builder = {
    sopsFile = ../secrets/albatross-builder.yaml;
  };

  nix = {
    buildMachines = [
      (rec {
        hostName = "albatross";
        system = "x86_64-linux";
        maxJobs = 32;
        speedFactor = maxJobs / config.nix.maxJobs;
        sshKey = config.sops.secrets.albatross_builder.path;
        sshUser = "cloud";
        supportedFeatures = [ "big-parallel" "kvm" ];
      })
    ];
    extraOptions = ''
      builders-use-substitutes = true
    '';
  };

  services.openssh.knownHosts.albatross-builder = {
    hostNames = [ "albatross" ];
    publicKey =
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBfj2qNy7s8RaOg/OtWdOW2S2wXe914NlIfB1WmZdW+r albatross-builder";
  };
}
