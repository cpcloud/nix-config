{
  programs.tmux = {
    enable = true;
    aggressiveResize = true;
    baseIndex = 1;
    clock24 = true;
    customPaneNavigationAndResize = true;
    # disableConfirmationPrompt = true;
    escapeTime = 0;
    historyLimit = 99999999;
    keyMode = "vi";
    shortcut = "g";
    terminal = "screen-256color";
    extraConfig = ''
      set -g status-bg black
      set -g status-fg white
      set -g status-left ""

      set -ga terminal-overrides ",xterm-256color:Tc"
      set-option -g renumber-windows on

      ## copy into clipboard
      bind C-c choose-buffer "run \"tmux save-buffer -b '%%' - | xsel -i -b\""

      ## Paste from clipboard
      bind C-v run "xsel -o -b | tmux load-buffer - && tmux paste-buffer"

      bind r move-window -r \; display "Panes reordered!"
      bind / list-keys

      set-window-option -g status-style bg=blue

      bind-key -n C-Space resize-pane -Z

      bind c new-window -c "#{pane_current_path}"
      bind '"' split-window -c "#{pane_current_path}"
      bind % split-window -h -c "#{pane_current_path}"
    '';
  };
}
