{ system ? "x86_64-linux" }:

let
  sources = import ../nix;
  config = { modulesPath, pkgs, ... }: {
    imports = [
      "${modulesPath}/installer/cd-dvd/installation-cd-graphical-plasma5-new-kernel.nix"
    ];

    services.pcscd.enable = true;
    services.udev.packages = with pkgs; [
      yubikey-personalization
      libu2f-host
    ];

    environment.systemPackages = with pkgs; [
      curl
      gnupg
      neovim
      paperkey
      pinentry-curses
      pinentry-qt
      wget
    ];

    programs = {
      ssh.startAgent = false;
      gnupg.agent = {
        enable = true;
        enableSSHSupport = true;
      };
    };
  };

  evalNixos = configuration: import "${sources.nixpkgs}/nixos" {
    inherit system configuration;
  };

in
{
  iso = (evalNixos config).config.system.build.isoImage;
}
