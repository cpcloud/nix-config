{ pkgs, ... }: {
  imports = [
    ./git.nix
    ./neovim
    ./starship.nix
    ./tmux.nix
    ./xdg.nix
    ./zsh.nix
    ./current_employer.nix
    ./docker.nix
  ];

  home.packages = with pkgs; [
    btop
    diskonaut
    fd
    file
    gping
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
    unzip
    usbutils
    taskwarrior-tui
  ];

  xdg.configFile."nixpkgs/config.nix".text = "{ allowUnfree = true; }";

  programs = {
    direnv = {
      enable = true;
      nix-direnv.enable = true;
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
    taskwarrior = {
      enable = true;
      colorTheme = "dark-256";
    };
  };
}
