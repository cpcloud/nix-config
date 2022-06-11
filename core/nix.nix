{ ... }: {
  nix = {
    settings.trusted-users = [ "root" "@wheel" ];
    optimise = {
      automatic = true;
      dates = [ "01:10" "12:10" ];
    };
    distributedBuilds = true;
  };

  sops.secrets.cachix = {
    sopsFile = ../secrets/cachix.yaml;
    key = "pat";
  };
}
