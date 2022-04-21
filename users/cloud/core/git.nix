{ pkgs, ... }: {

  home.packages = with pkgs.gitAndTools; [
    git-extras
  ];

  programs = {
    git = {
      enable = true;
      userName = "Phillip Cloud";
      userEmail = "417981+cpcloud@users.noreply.github.com";
      extraConfig = {
        advice.skippedCherryPicks = false;
        "difftool \"nvr\"".cmd = "nvr -s -d $LOCAL $REMOTE";
        "mergetool \"nvr\"".cmd = "nvr -s -d $LOCAL $BASE $REMOTE $MERGED -c 'wincmd J | wincmd ='";
        core = {
          editor = "nvr --remote-wait-silent";
          pager = "${pkgs.gitAndTools.delta}/bin/delta --dark";
        };
        diff.tool = "nvr";
        difftool.prompt = true;
        github.user = "cpcloud";
        init.defaultBranch = "main";
        merge.tool = "nvr";
        mergetool.prompt = true;
        pull.rebase = true;
        rebase.autoSquash = true;
        credential."https://github.com".helper = "${pkgs.gh}/bin/gh auth git-credential";
      };
    };

    gh = {
      enable = true;
      settings = {
        git_protocol = "https";
      };
    };
  };
}
