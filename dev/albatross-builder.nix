{ config, pkgs, ... }: {
  sops.secrets.albatross_builder = {
    sopsFile = ../secrets/albatross-builder.yaml;
  };

  nix = {
    buildMachines = [
      rec {
        hostName = "albatross";
        systems = [ "x86_64-linux" "aarch64-linux" ];
        maxJobs = 32;
        speedFactor = pkgs.getSpeedFactor { inherit maxJobs config; };
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
