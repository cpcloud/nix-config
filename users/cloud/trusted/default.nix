hostName:
{ ... }: {
  imports = [
    ./gpg.nix
    ((import ./ssh.nix) hostName)
  ];

  programs.git.signing = {
    key = "0x898EA27607D72CCE";
    signByDefault = true;
  };

  programs.gpg.settings = {
    default-key = "0x898EA27607D72CCE";
    trusted-key = "0x898EA27607D72CCE";
  };

  services.gpg-agent = {
    pinentryFlavor = "curses";
    enable = true;
    enableExtraSocket = true;
    enableScDaemon = true;
    enableSshSupport = true;
    defaultCacheTtl = 34560000;
    maxCacheTtl = 34560000;
  };
}
