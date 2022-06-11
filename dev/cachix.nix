{ ... }: {
  sops.secrets.cachix = {
    sopsFile = ../secrets/cachix.yaml;
    key = "pat";
  };
}
