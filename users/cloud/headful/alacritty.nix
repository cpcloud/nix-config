{ pkgs, lib, ... }:
let
  size = lib.mkDefault 8;
  family = "monospace";
  themeSettingsFile = pkgs.fetchurl {
    url = "https://raw.githubusercontent.com/jesse-c/ayu-alacritty/master/alacritty-ayu-dark.yml";
    sha256 = "sha256-6t52q6LB0Kj+6RuX1PgwtD8DvxVnCkC8NLU/TZo6BOo=";
  };
in
{
  programs.alacritty = {
    enable = true;
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
