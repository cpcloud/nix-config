{ pkgs, ... }:
let
  dummyConfig = pkgs.writeText "configuration.nix" ''
    assert builtins.trace "This is a dummy config, use nixus!" false;
    {}
  '';
  sources = import ../nix;
in
{
  imports = [
    (import sources.home-manager)
    ./aspell.nix
    ./nix.nix
    ./openssh.nix
    ./tmux.nix
    ./zsh.nix
    ../dev/nix-community-substituters.nix
    ./tailscale.nix
    "${sources.sops-nix}/modules/sops"
  ];

  nix = {
    autoOptimiseStore = true;

    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 30d";
    };

    extraOptions = ''
      keep-outputs = true
      keep-derivations = true
      builders-use-substitutes = true
    '';

    nixPath = [
      "nixos-config=${dummyConfig}"
      "nixpkgs=/run/current-system/nixpkgs"
      "nixos-hardware=/run/current-system/nixos-hardware"
    ];

    package = pkgs.nix_2_4;
  };

  environment = {
    systemPackages = [ pkgs.pinentry-curses ];
    etc."nixos/configuration.nix".source = dummyConfig;
  };

  home-manager.useGlobalPkgs = true;

  i18n = {
    supportedLocales = [ "en_US.UTF-8/UTF-8" ];
    defaultLocale = "en_US.UTF-8";
  };

  console.keyMap = "us";

  security = {
    sudo = {
      enable = true;
      # probably not great security/accidentally-delete-everything-wise, but
      # life is easier this way
      wheelNeedsPassword = false;
    };
  };

  programs.ssh.startAgent = false;

  systemd = {
    extraConfig = ''
      DefaultTimeoutStopSec=15s
    '';

    coredump = {
      enable = true;
      extraConfig = ''
        ProcessSizeMax=32G
        ExternalSizeMax=32G
        JournalSizeMax=32G
      '';
    };
  };


  system = {
    extraSystemBuilderCmds = ''
      ln -sv ${pkgs.path} $out/nixpkgs
      ln -sv ${../overlays} $out/overlays
      ln -sv ${sources.nixos-hardware} $out/nixos-hardware
    '';

    stateVersion = "21.11";
  };
}
