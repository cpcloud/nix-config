{ pkgs, ... }: {

  home.packages = with pkgs; [
    berglas
    gnome3.seahorse
  ];

  services = {
    gnome-keyring = {
      enable = true;
      components = [ "pkcs11" "secrets" "ssh" ];
    };
  };
}
