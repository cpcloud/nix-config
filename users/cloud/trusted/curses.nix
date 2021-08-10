{ pkgs, lib, ... }: {
  imports = [ ./. ];

  services.gpg-agent.pinentryFlavor = "curses";
}
