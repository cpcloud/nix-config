{ config, ... }: {
  sops.secrets.albatross_builder = {
    sopsFile = ../secrets/albatross-builder.yaml;
  };

  nix = {
    buildMachines = [
      rec {
        hostName = "albatross";
        system = "x86_64-linux";
        maxJobs = 32;
        speedFactor = maxJobs / config.nix.settings.max-jobs;
        sshKey = config.sops.secrets.albatross_builder.path;
        sshUser = "cloud";
        supportedFeatures = [ "big-parallel" "kvm" ];
      }
    ];
    extraOptions = ''
      builders-use-substitutes = true
    '';
  };
}
