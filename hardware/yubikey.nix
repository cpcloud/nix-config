{ pkgs, ... }: {
  services = {
    pcscd.enable = true;
    udev.packages = with pkgs; [
      libu2f-host
      yubikey-personalization
    ];
  };
}
