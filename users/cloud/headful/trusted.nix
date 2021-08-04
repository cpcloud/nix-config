{ pkgs, ... }: {
  imports = [
    ../trusted
  ];

  home.packages = with pkgs; [
    pinentry-curses
  ];

  services.gpg-agent.pinentryFlavor = "curses";
}
