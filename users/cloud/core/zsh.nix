{ config, pkgs, lib, ... }:
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
  # ignore history of things that look like keys
  historyIgnorePatterns = [
    "CREDENTIALS=([^ ]+)"
    "tskey-([^ ]+)"
    "pul-([^ ]+)"
    "ghp_([^ ]+)"
  ];
in
{
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

      history = {
        expireDuplicatesFirst = true;
        extended = true;
        ignoreDups = true;
        size = shellConfig.historySize;
        save = shellConfig.historySize;
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
        MAMBA_NO_BANNER = "1";
      };

      plugins = [
        {
          # https://github.com/hlissner/zsh-autopair
          name = "zsh-autopair";
          file = "zsh-autopair.plugin.zsh";
          src = pkgs.fetchFromGitHub {
            owner = "hlissner";
            repo = "zsh-autopair";
            rev = "9d003fc02dbaa6db06e6b12e8c271398478e0b5d";
            sha256 = "0s4xj7yv75lpbcwl4s8rgsaa72b41vy6nhhc5ndl7lirb9nl61l7";
          };
        }
        {
          # https://github.com/zdharma/fast-syntax-highlighting
          name = "fast-syntax-highlighting";
          file = "fast-syntax-highlighting.plugin.zsh";
          src = pkgs.fetchFromGitHub {
            owner = "zdharma";
            repo = "fast-syntax-highlighting";
            rev = "817916dfa907d179f0d46d8de355e883cf67bd97";
            sha256 = "0m102makrfz1ibxq8rx77nngjyhdqrm8hsrr9342zzhq1nf4wxxc";
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

        mkdir -p "${config.programs.zsh.sessionVariables.FAST_WORK_DIR}"

        ${zshFunctions}

        HISTORY_EXCLUDE_PATTERN='^ |//([^/]+:[^/]+)@|KEY=([^ ]+)|TOKEN=([^ ]+)|BEARER=([^ ]+)|PASSWORD=([^ ]+)|Authorization: *([^'"'"'\"]+)|-us?e?r? ([^:]+:[^:]+) '
        export HISTORY_EXCLUDE_PATTERN="${lib.concatStringsSep "|" historyIgnorePatterns}|$HISTORY_EXCLUDE_PATTERN";
        source ${./zshaddhistory.zsh}
      '';
    };
  };
}
