{ pkgs, lib, ... }:
let
  size = lib.mkDefault 8;
  family = "monospace";
  theme = "gruvbox_dark.yaml";
  themeSettingsFile = pkgs.fetchurl {
    url = "https://raw.githubusercontent.com/eendroroy/alacritty-theme/master/themes/${theme}";
    sha256 = "0fk59sk9nhlpjbs1h8symmjs247vv6lpic7xjr8r2d5aixh62mq3";
  };
in
{
  programs.alacritty = {
    enable = pkgs.stdenv.isx86_64;
    settings = lib.strings.fromJSON
      (
        lib.readFile (
          pkgs.runCommand
            "alacritty_settings.json"
            { buildInputs = [ pkgs.yj ]; }
            ''yj -yj < "${themeSettingsFile}" > $out''
        )
      ) // {
      env.TERM = "xterm-256color";
      font = (lib.listToAttrs (
        map
          (style: {
            name = lib.toLower style;
            value = { inherit family style; };
          }) [ "Bold" "Italic" "Regular" ]
      )) // { inherit size; };
    };
  };
}
