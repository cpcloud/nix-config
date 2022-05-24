{ config, ... }: {
  sops.secrets.falcon_builder = {
    sopsFile = ../secrets/falcon-builder.yaml;
  };

  nix = {
    buildMachines = [
      (rec {
        hostName = "falcon";
        system = "x86_64-linux";
        maxJobs = 32;
        speedFactor = maxJobs / config.nix.settings.max-jobs;
        sshKey = config.sops.secrets.falcon_builder.path;
        sshUser = "cloud";
        supportedFeatures = [ "big-parallel" "kvm" ];
      })
    ];
    extraOptions = ''
      builders-use-substitutes = true
    '';
  };
}
