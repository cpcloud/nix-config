{ config, pkgs, ... }:
let
  shellConfig = pkgs.callPackage ./shell-config.nix { inherit config; };
  zshFunctions = ''
    function clip {
      local filetype
      filetype="$(${pkgs.file}/bin/file -b --mime-type "$1")"

      "${pkgs.xclip}/bin/xclip" -selection clipboard -t "$filetype" < "$1"
    }

    function mkcd {
      "${pkgs.coreutils}/bin/mkdir" -p "$1"

      if which z > /dev/null; then
        z "$1"
      else
        cd "$1"
      fi
    }

    function gpnb {
      local remote="''${1:-origin}"

      if [ "$#" -gt 0 ]; then
        shift 1
      fi

      "${pkgs.git}/bin/git" push --set-upstream "$@" "$remote" HEAD
    }
  '';
in
rec {
  programs = {
    scmpuff = {
      enable = true;
      enableBashIntegration = false;
      enableZshIntegration = true;
    };

    starship.enableZshIntegration = true;
    direnv.enableZshIntegration = true;
    fzf.enableZshIntegration = true;
    zoxide.enableZshIntegration = true;

    zsh = {
      enable = true;
      enableCompletion = true;
      enableAutosuggestions = true;
      autocd = true;
      dotDir = ".config/zsh";

      inherit (shellConfig) shellAliases;

      history = rec {
        expireDuplicatesFirst = true;
        extended = true;
        ignoreDups = true;
        size = shellConfig.historySize;
        save = size;
        share = true;
      };

      defaultKeymap = "emacs";

      sessionVariables = {
        BROWSER = "brave";
        RPROMPT = "";
        DISABLE_UNTRACKED_FILES_DIRTY = true;
        GDK_DPI_SCALE = 0.5;
        GDK_SCALE = 0.5;
        GITHUB_USER = "cpcloud";
        HIST_STAMPS = "yyyy-mm-dd";
        PAGER = "less";
        FAST_WORK_DIR = "${config.xdg.cacheHome}/zsh";
        LESSHISTFILE = "${config.xdg.dataHome}/less_history";
        CARGO_HOME = "${config.xdg.cacheHome}/cargo";
        XDG_BIN_DIR = "$HOME/bin";
      };

      plugins = [
        {
          # https://github.com/hlissner/zsh-autopair
          name = "zsh-autopair";
          file = "zsh-autopair.plugin.zsh";
          src = pkgs.fetchFromGitHub {
            owner = "hlissner";
            repo = "zsh-autopair";
            rev = "34a8bca0c18fcf3ab1561caef9790abffc1d3d49";
            sha256 = "1h0vm2dgrmb8i2pvsgis3lshc5b0ad846836m62y8h3rdb3zmpy1";
          };
        }
        {
          # https://github.com/zdharma/fast-syntax-highlighting
          name = "fast-syntax-highlighting";
          file = "fast-syntax-highlighting.plugin.zsh";
          src = pkgs.fetchFromGitHub {
            owner = "zdharma";
            repo = "fast-syntax-highlighting";
            rev = "a62d721affc771de2c78201d868d80668a84c1e1";
            sha256 = "0kwrkxkgsx9cchdrp9jg3p47y6h9w6dgv6zqapzczmx7slgmf4p3";
          };
        }
      ];

      initExtra = ''
        unsetopt auto_name_dirs
        setopt extended_glob

        autoload -U select-word-style
        select-word-style bash

        export WORDCHARS='.-_'

        if [ "$(whence -w run-help | cut -d ' ' -f2)" = "alias" ]; then
          unalias run-help
        fi
        autoload run-help

        bindkey "\C-p" history-beginning-search-backward
        bindkey "\C-n" history-beginning-search-forward

        bindkey "\e[A" history-beginning-search-backward
        bindkey "\e[B" history-beginning-search-forward

        if [ -n "$DISPLAY" ]; then
          # set the key repeat rate and delay
          xset r rate 200 30

          # turn off powersave/sleep
          xset -dpms
          xset s off
        fi

        if which setxkbmap > /dev/null; then
          setxkbmap -option ctrl:nocaps -option altwin:swap_lalt_lwin
        fi

        mkdir -p "${config.programs.zsh.sessionVariables.FAST_WORK_DIR}"

        ${zshFunctions}
      '';
    };
  };
}
