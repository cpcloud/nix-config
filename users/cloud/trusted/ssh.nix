{ lib, ... }:
let
  yubikeyModels = [
    "5_nano"
    "5_nfc"
    "5c_nano"
  ];
  genYubikeyPubKeyPath = model: "~/.ssh/id_rsa_yubikey_${model}";
  identityFileConfig = lib.concatMapStringsSep
    "\n"
    (model: "IdentityFile ${genYubikeyPubKeyPath model}")
    yubikeyModels;
in
{
  programs.ssh = {
    enable = true;
    forwardAgent = false;
    hashKnownHosts = true;
    controlMaster = "auto";
    controlPath = "~/.ssh/a-%C";
    controlPersist = "30m";
    extraConfig = ''
      IdentityAgent /run/user/1000/gnupg/S.gpg-agent.ssh
      ChallengeResponseAuthentication no
      AddKeysToAgent yes
      ForwardX11 no
      ForwardX11Trusted no
      StrictHostKeyChecking ask
      VerifyHostKeyDNS yes
      IdentitiesOnly yes
      ${identityFileConfig}
      ServerAliveCountMax 5
      ServerAliveInterval 60
    '';

    matchBlocks = {
      "github.com" = {
        hostname = "github.com";
        identityFile = map genYubikeyPubKeyPath yubikeyModels;
        user = "git";
      };
    };
  };
}
