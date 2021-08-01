{ ... }: {
  nix = {
    trustedUsers = [ "root" "@wheel" ];
    optimise = {
      automatic = true;
      dates = [ "01:10" "12:10" ];
    };
    distributedBuilds = true;
  };
}
