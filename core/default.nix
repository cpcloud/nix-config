{ pkgs, config, ... }:
let
  dummyConfig = pkgs.writeText "configuration.nix" ''
    assert builtins.trace "This is a dummy config, use nixus!" false;
    {}
  '';
in
{
  imports = [
    ./aspell.nix
    ./nix.nix
    ./openssh.nix
    ./tmux.nix
    ./zsh.nix
    ../dev/nix-community-substituters.nix
    ./tailscale.nix
  ];

  nix = {
    settings.auto-optimise-store = true;

    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 30d";
    };

    extraOptions = ''
      keep-outputs = true
      keep-derivations = true
      builders-use-substitutes = true
      experimental-features = nix-command flakes
    '';

    nixPath = [
      "nixos-config=${dummyConfig}"
      "nixpkgs=/run/current-system/nixpkgs"
      "nixos-hardware=/run/current-system/nixos-hardware"
    ];

    package = pkgs.nix;
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

  console = if config.services.xserver.enable then { useXkbConfig = true; } else { keyMap = "us"; };

  services.tlp = {
    enable = true;
    settings = {
      USB_AUTOSUSPEND = 0;
      USB_DENYLIST = "05a7:4040";
      USB_EXCLUDE_BTUSB = 1;
      USB_EXCLUDE_AUDIO = 1;
      USB_EXCLUDE_WWAN = 1;
      RUNTIME_PM_DRIVER_DENYLIST = "nvidia";
      SOUND_POWER_SAVE_ON_AC = 0;
      SOUND_POWER_SAVE_ON_BAT = 0;
      SOUND_POWER_SAVE_CONTROLLER = "N";
    };
  };

  security = {
    sudo = {
      enable = true;
      # probably not great security/accidentally-delete-everything-wise, but
      # life is easier this way
      wheelNeedsPassword = false;
    };
  };

  nixpkgs = {
    config.contentAddressedByDefault = false;
    overlays = [
      (import ../nix/snowflake-overlays/gh.nix { inherit config; })
      (import ../nix/snowflake-overlays/zulip-term.nix { inherit config; })
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
      ln -sv ${../nix/overlays} $out/overlays
    '';

    stateVersion = "21.11";
  };
}
