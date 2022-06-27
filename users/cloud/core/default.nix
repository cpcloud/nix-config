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
    (pkgs.writeShellApplication {
      name = "pyver";
      runtimeInputs = [ ];
      text = ''
        python -c "import ''${1}; print(''${1}.__version__)"
      '';
    })
  ];

  home.stateVersion = import ../../../nix/state-version.nix;

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
  };
}
