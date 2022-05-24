{ config, lib, pkgs, ... }:
let
  idRsaYubikey5Nano = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCc594BHX4DRSK8vOYrZf/baTLiRwDn67ljSKO99i4pNVOeEHOBNb9zONSqQSVKO8/cIgElpncZa4nqdCYQoWzGvft6e11QMBM94avlrHrT45vgdYZM8doIepOb0wWlKp/ud7CnXFolv2TmWL6fty7LHRF9ThgDVNkjukX22jwtRAQ3nxPKkJ5DOy2Jhtk2lBja0R9W6+lkJo3ynurjbpxYbrAPo6Baw9uyIdypWOWNM0uVqGE1C1WkY76j0R1RT3AvkS5I98oREneibZTQHbz6Shh4QxDArm7TEt5jez+8Zj0zdHRIEfKiIDtFYVcnkKB5Nq4rAO9dTd1jDRSLZchJK+gIYO/iWMbJ47C0eNpCwoUbajn9729wGB3XFIrm1fxGp2dC/9ebsUKq/oOh4/vCVrotHEZO/pMqCWU/ggxtyH+LdmNi8kEWtOLyZbdkszIA0zJdLwt9OjkCcMLt+qVokOd3NandECIW0h+iQIG9z0/S0qNf+d7Kv3sQ5e7Vc7MSJS2a7hzKR0ePhLYR2C0zQNItDXNwLwPoHIt6hluFRgljazT3bwB5JLsGV+LVnTkZqvyp9FYBqD/48v2z2gi+NHO/BZXV0w3y5EoPq4zsP8WRkTG8gb8P/cwaquCqeaybBMWWPuSC09vhIRzd+ZZ0bfiA0WNfeUGTnwx3sORi6Q== cardno:000611103981";
  idRsaYubikey5Nfc = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCc594BHX4DRSK8vOYrZf/baTLiRwDn67ljSKO99i4pNVOeEHOBNb9zONSqQSVKO8/cIgElpncZa4nqdCYQoWzGvft6e11QMBM94avlrHrT45vgdYZM8doIepOb0wWlKp/ud7CnXFolv2TmWL6fty7LHRF9ThgDVNkjukX22jwtRAQ3nxPKkJ5DOy2Jhtk2lBja0R9W6+lkJo3ynurjbpxYbrAPo6Baw9uyIdypWOWNM0uVqGE1C1WkY76j0R1RT3AvkS5I98oREneibZTQHbz6Shh4QxDArm7TEt5jez+8Zj0zdHRIEfKiIDtFYVcnkKB5Nq4rAO9dTd1jDRSLZchJK+gIYO/iWMbJ47C0eNpCwoUbajn9729wGB3XFIrm1fxGp2dC/9ebsUKq/oOh4/vCVrotHEZO/pMqCWU/ggxtyH+LdmNi8kEWtOLyZbdkszIA0zJdLwt9OjkCcMLt+qVokOd3NandECIW0h+iQIG9z0/S0qNf+d7Kv3sQ5e7Vc7MSJS2a7hzKR0ePhLYR2C0zQNItDXNwLwPoHIt6hluFRgljazT3bwB5JLsGV+LVnTkZqvyp9FYBqD/48v2z2gi+NHO/BZXV0w3y5EoPq4zsP8WRkTG8gb8P/cwaquCqeaybBMWWPuSC09vhIRzd+ZZ0bfiA0WNfeUGTnwx3sORi6Q== cardno:000614971116";
  idRsaYubikey5CNano = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCc594BHX4DRSK8vOYrZf/baTLiRwDn67ljSKO99i4pNVOeEHOBNb9zONSqQSVKO8/cIgElpncZa4nqdCYQoWzGvft6e11QMBM94avlrHrT45vgdYZM8doIepOb0wWlKp/ud7CnXFolv2TmWL6fty7LHRF9ThgDVNkjukX22jwtRAQ3nxPKkJ5DOy2Jhtk2lBja0R9W6+lkJo3ynurjbpxYbrAPo6Baw9uyIdypWOWNM0uVqGE1C1WkY76j0R1RT3AvkS5I98oREneibZTQHbz6Shh4QxDArm7TEt5jez+8Zj0zdHRIEfKiIDtFYVcnkKB5Nq4rAO9dTd1jDRSLZchJK+gIYO/iWMbJ47C0eNpCwoUbajn9729wGB3XFIrm1fxGp2dC/9ebsUKq/oOh4/vCVrotHEZO/pMqCWU/ggxtyH+LdmNi8kEWtOLyZbdkszIA0zJdLwt9OjkCcMLt+qVokOd3NandECIW0h+iQIG9z0/S0qNf+d7Kv3sQ5e7Vc7MSJS2a7hzKR0ePhLYR2C0zQNItDXNwLwPoHIt6hluFRgljazT3bwB5JLsGV+LVnTkZqvyp9FYBqD/48v2z2gi+NHO/BZXV0w3y5EoPq4zsP8WRkTG8gb8P/cwaquCqeaybBMWWPuSC09vhIRzd+ZZ0bfiA0WNfeUGTnwx3sORi6Q== cardno:000616360817";
  albatrossBuilderPubKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBfj2qNy7s8RaOg/OtWdOW2S2wXe914NlIfB1WmZdW+r albatross-builder";
in
{
  # for coral edgetpus
  users.groups.plugdev.members = [ "cloud" ];

  services.openssh.knownHosts.albatross-builder = {
    extraHostNames = [ "albatross" ];
    publicKey = albatrossBuilderPubKey;
  };

  users.users.cloud = {
    isNormalUser = true;
    createHome = true;
    description = "Phillip Cloud";

    extraGroups = [
      "wheel"
      "dialout"
      "video"
      config.users.groups.keys.name
    ]
    ++ lib.optionals config.networking.networkmanager.enable [ "networkmanager" ]
    ++ lib.optionals config.programs.wireshark.enable [ "wireshark" ]
    ++ lib.optionals config.virtualisation.docker.enable [ "docker" ]
    ++ lib.optionals config.virtualisation.podman.enable [ "podman" ]
    ++ lib.optionals config.virtualisation.virtualbox.host.enable [ "vboxsf" "vboxusers" ];

    shell = lib.mkIf config.programs.zsh.enable pkgs.zsh;
    openssh.authorizedKeys.keys = [
      idRsaYubikey5Nano
      idRsaYubikey5Nfc
      idRsaYubikey5CNano
      albatrossBuilderPubKey
    ];
  };

  sops.secrets.github-gh-token = {
    sopsFile = ../../secrets/github-gh-token.yaml;
    owner = "cloud";
    key = "token";
  };

  sops.secrets.ursalabs-zulip = {
    sopsFile = ../../secrets/ursalabs-zulip.yaml;
    owner = "cloud";
    key = "config";
  };

  home-manager.users.cloud = { ... }: {
    imports = [
      ./core
      ./dev
    ] ++ lib.optionals config.services.xserver.enable [
      ./headful
    ];

    home = {
      enableNixpkgsReleaseCheck = false;

      file.".ssh/id_rsa_yubikey_5_nano.pub".text = idRsaYubikey5Nano;
      file.".ssh/id_rsa_yubikey_5_nfc.pub".text = idRsaYubikey5Nfc;
      file.".ssh/id_rsa_yubikey_5c_nano.pub".text = idRsaYubikey5CNano;
    };

    xdg.configFile =
      let
        podmanEnabled = config.virtualisation.podman.enable;
        podmanNvidiaEnabled = podmanEnabled && config.virtualisation.podman.enableNvidia;
      in
      lib.optionalAttrs podmanNvidiaEnabled {
        "nvidia-container-runtime/config.toml".source = "${pkgs.nvidia-podman}/etc/nvidia-container-runtime/config.toml";
      };
  };
}
