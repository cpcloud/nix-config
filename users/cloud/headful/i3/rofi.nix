{
  programs.rofi = {
    enable = true;
    theme = "Arc-Dark";
    font = "monospace 10";
    extraConfig = {
      modi = "window,run,drun,ssh,combi,keys";
      matching = "fuzzy";
      sort = true;
      sorting-method = "fzf";
      combi-modi = "window,drun,ssh,run";
    };
  };
}
