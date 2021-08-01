{ pkgs, ... }:
let
  font = "FiraCode";
in
{
  fonts = {
    enableDefaultFonts = false;
    enableGhostscriptFonts = false;
    fontconfig = {
      defaultFonts = {
        sansSerif = [ "IBM Plex Sans" ];
        serif = [ "IBM Plex Sans" ];
        monospace = [ "${font} Nerd Font" ];
        emoji = [ "Noto Color Emoji" ];
      };
      localConf = ''
        <?xml version="1.0"?>
        <!DOCTYPE fontconfig SYSTEM "fonts.dtd">
        <fontconfig>
            <alias binding="weak">
                <family>monospace</family>
                <prefer>
                    <family>emoji</family>
                </prefer>
            </alias>
            <alias binding="weak">
                <family>sans-serif</family>
                <prefer>
                    <family>emoji</family>
                </prefer>
            </alias>
            <alias binding="weak">
                <family>serif</family>
                <prefer>
                    <family>emoji</family>
                </prefer>
            </alias>
        </fontconfig>
      '';
    };
    fonts = with pkgs; [
      (nerdfonts.override { fonts = [ font ]; })
      ibm-plex
      noto-fonts-cjk
      noto-fonts-emoji
    ];
  };
}
