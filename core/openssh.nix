{ lib, ... }: {
  services.openssh = {
    enable = true;
    kbdInteractiveAuthentication = false;
    passwordAuthentication = false;
    permitRootLogin = lib.mkDefault "no";
    extraConfig = ''
      StreamLocalBindUnlink yes
    '';
  };
}
