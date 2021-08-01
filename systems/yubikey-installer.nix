{ system ? "x86_64-linux" }:

let
  config = { pkgs, ... }:
    with pkgs; {
      imports = [
        <nixpkgs/nixos/modules/installer/cd-dvd/installation-cd-graphical-plasma5.nix>
        <nixos-hardware/dell/xps/13-9310>
      ];

      services.pcscd.enable = true;
      services.udev.packages = [ yubikey-personalization ];

      environment.systemPackages = [
        gnupg
        pinentry-curses
        pinentry-qt
        paperkey
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

  evalNixos = configuration: import <nixpkgs/nixos> {
    inherit system configuration;
  };

in
{
  iso = (evalNixos config).config.system.build.isoImage;
}
