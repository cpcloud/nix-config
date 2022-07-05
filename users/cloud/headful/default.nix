{ pkgs, lib, ... }:
let
  km = pkgs.writeShellApplication {
    name = "km";
    runtimeInputs = [ pkgs.xorg.setxkbmap ];
    text = ''
      setxkbmap -option ctrl:nocaps -option altwin:swap_lalt_lwin
    '';
  };
in
{
  imports = [ ./i3 ];

  home.packages = with pkgs; [
    arandr
    pavucontrol
    signal-desktop
    xclip
    xsel
    zoom-us
    km
  ];

  gtk.enable = true;

  programs.brave.enable = true;

  xsession = {
    enable = true;
    profileExtra = ''
      xrdb ~/.Xresources
    '';
  };

  services.blueman-applet.enable = true;

  systemd.user = {
    targets.i3-session = {
      Unit = {
        Description = "i3 session";
        Documentation = [ "man:systemd.special(7)" ];
        BindsTo = [ "graphical-session.target" ];
        Wants = [ "graphical-session-pre.target" ];
        After = [ "graphical-session-pre.target" ];
      };
    };

    services = {
      polybar = {
        Unit.PartOf = lib.mkForce [ "i3-session.target" ];
        Install.WantedBy = lib.mkForce [ "i3-session.target" ];
      };
    };
  };
}
