{ pkgs, lib, ... }: {
  imports = [
    ./alacritty.nix
    ./i3/i3.nix
    ./i3/polybar.nix
    ./rofi.nix
  ];

  home.packages = with pkgs; [
    arandr
    pavucontrol
    signal-desktop
    xclip
    xsel
    zoom-us
    zulip-term
  ];

  gtk.enable = true;

  programs = {
    brave.enable = true;
  };

  xsession = {
    enable = true;
    profileExtra = ''
      export MOZ_USE_XINPUT2=1
      export _JAVA_OPTIONS="-Dawt.useSystemAAFontSettings=on -Dswing.aatext=true -Dsun.java2d.xrender=true"
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
