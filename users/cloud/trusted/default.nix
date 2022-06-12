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
}
