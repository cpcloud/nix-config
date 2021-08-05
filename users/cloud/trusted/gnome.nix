{ pkgs, lib, ... }: {
  imports = [ ./. ];

  home.packages = with pkgs; [
    pinentry-gnome
  ];

  services.gpg-agent.pinentryFlavor = "gnome3";
}
