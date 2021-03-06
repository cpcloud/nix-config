{ pkgs, ... }: {
  imports = [
    ./fonts.nix
    ./i3.nix
    ./xserver.nix
  ];

  environment.systemPackages = with pkgs; [
    gnome3.adwaita-icon-theme
  ];

  services.xserver.displayManager.lightdm.enable = true;
}
