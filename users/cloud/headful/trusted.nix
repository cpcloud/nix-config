{ pkgs, ... }: {
  imports = [
    ../trusted
  ];

  home.packages = with pkgs; [
    pinentry-gnome
  ];

  services.gpg-agent.pinentryFlavor = "gnome3";
}
