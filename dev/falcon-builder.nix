{ config, pkgs, ... }: {
  sops.secrets.falcon_builder = {
    sopsFile = ../secrets/falcon-builder.yaml;
  };

  nix = {
    buildMachines = [
      rec {
        hostName = "falcon";
        systems = [ "x86_64-linux" "aarch64-linux" ];
        maxJobs = 32;
        speedFactor = pkgs.getSpeedFactor {
          inherit maxJobs config;
          isCloudHost = true;
        };
        sshKey = config.sops.secrets.falcon_builder.path;
        sshUser = "cloud";
        supportedFeatures = [ "big-parallel" "kvm" ];
      }
    ];
    extraOptions = ''
      builders-use-substitutes = true
    '';
  };
}
