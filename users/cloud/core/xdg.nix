{ ... }: {
  xdg = {
    enable = true;
    userDirs = {
      enable = true;
      desktop = "$HOME/desktop";
      documents = "$HOME/documents";
      download = "$HOME/downloads";
      music = "$HOME/music";
      pictures = "$HOME/pictures";
      publicShare = "$HOME/opt";
      templates = "$HOME/opt";
      videos = "$HOME/videos";
      extraConfig = {
        XDG_BIN_DIR = "$HOME/bin";
      };
    };
  };
}
