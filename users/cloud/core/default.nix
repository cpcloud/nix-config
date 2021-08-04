{ pkgs, ... }: {
  imports = [
    ./git.nix
    ./neovim
    ./starship.nix
    ./tmux.nix
    ./xdg.nix
    ./zsh.nix
    ./current_employer.nix
  ];

  home.packages = with pkgs; [
    bpytop
    diskonaut
    fd
    file
    hyperfine
    lshw
    nix-index
    pax-utils # for lddtree
    pigz
    prettyping
    pv
    ripgrep
    sd
    speedtest-cli
    tldr
    usbutils
  ];

  xdg.configFile."nixpkgs/config.nix".text = "{ allowUnfree = true; }";

  programs = {
    direnv = {
      enable = true;
      nix-direnv.enable = true;
    };

    htop = {
      enable = true;
      settings = {
        vim_mode = true;
        tree_view = false;
        show_cpu_usage = true;
        left_meters = [
          "AllCPUs4"
          "Memory"
          "Swap"
        ];
        right_meters = [
          "Tasks"
          "LoadAverage"
          "Uptime"
        ];
      };
    };

    bat = {
      enable = true;
      config.theme = "gruvbox-dark";
    };

    exa.enable = true;
    fzf.enable = true;
    jq.enable = true;
    man.enable = true;
    info.enable = true;
    zoxide.enable = true;
    gpg.enable = true;
  };
}
