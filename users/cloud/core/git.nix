{ pkgs, ... }: {

  home.packages = with pkgs.gitAndTools; [
    git-extras
    commitizen
  ];

  programs = {
    git = {
      enable = true;
      userName = "Phillip Cloud";
      userEmail = "cpcloud@gmail.com";
      extraConfig = {
        core.pager = "${pkgs.gitAndTools.delta}/bin/delta --dark";
        difftool.prompt = true;
        github.user = "cpcloud";
        mergetool.prompt = true;
        pull.rebase = true;
        rebase.autoSquash = true;
      };
    };

    gh = {
      enable = true;
      gitProtocol = "ssh";
    };
  };
}
