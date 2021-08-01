{ pkgs, ... }: {

  environment.systemPackages = with pkgs.aspellDicts; [
    en
    en-computers
  ];

  environment.etc."aspell.conf".text = ''
    master en_US
    extra-dicts en-computers.rws
  '';
}
