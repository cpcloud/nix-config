{ lib, ... }: {
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
      StrictHostKeyChecking ask
      VerifyHostKeyDNS yes
      IdentitiesOnly yes
      ServerAliveCountMax 5
      ServerAliveInterval 60
    '';

    matchBlocks = {
      "github.com" = {
        hostname = "github.com";
        identityFile = "~/.ssh/id_rsa_yubikey.pub";
        user = "git";
      };
    };
  };
}
