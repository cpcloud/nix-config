{ lib, ... }: {
  services.openssh = {
    enable = true;
    challengeResponseAuthentication = false;
    passwordAuthentication = false;
    permitRootLogin = lib.mkDefault "no";
  };
}
