{ pkgs, config, ... }:
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

  nix.extraOptions = ''
    keep-outputs = true
    keep-derivations = true
  '';

  environment.systemPackages = with pkgs; [
    (writeShellScriptBin "nix-flakes" ''
      exec ${nixUnstable}/bin/nix --experimental-features "nix-command flakes" "$@"
    '')
    wireguard-tools
    cachix
  ];

  environment.etc."nixos/configuration.nix".source = dummyConfig;

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

  nix.nixPath = [
    "nixos-config=${dummyConfig}"
    "nixpkgs=/run/current-system/nixpkgs"
    "nixos-hardware=/run/current-system/nixos-hardware"
  ];

  nixpkgs = {
    config.allowUnfree = true;

    overlays = [
      # exa requires pandoc which builds ghc from scratch for some reason
      (import ../overlays/exa.nix)
      (import ../overlays/nix-direnv.nix)
      (import ../overlays/weechat.nix)
      (import ../overlays/v4l-utils.nix)
      (import ../overlays/ayu-theme-gtk.nix)
      (import ../overlays/gh.nix { inherit config; })
      (import ../overlays/linux-lto.nix)
      (import ../overlays/spawn.nix)
      (import ../overlays/write-sane-shell-script-bin.nix)
      (import ../overlays/drunmenu.nix)
      (import ../overlays/emojimenu.nix)
    ];
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
