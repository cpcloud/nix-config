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

    exa.enable = true;
    bat.enable = true;
    fzf.enable = true;
    jq.enable = true;
    man.enable = true;
    info.enable = true;
    zoxide.enable = true;

    keychain = {
      enable = true;
      enableZshIntegration = true;
      keys = [
        "google_compute_engine"
        "id_ed25519"
        "id_rsa"
      ];
    };
  };
}
