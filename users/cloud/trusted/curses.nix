{ pkgs, lib, ... }: {
  imports = [ ./. ];

  home.packages = with pkgs; [
    pinentry-curses
  ];

  services.gpg-agent.pinentryFlavor = "curses";
}
