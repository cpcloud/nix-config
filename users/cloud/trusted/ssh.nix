hostName:
{ lib, pkgs, ... }:
let
  yubikeyModels = [
    "5_nano"
    "5_nfc"
    "5c_nano"
  ];
  genYubikeyPubKeyPath = model: "~/.ssh/id_rsa_yubikey_${model}.pub";
  identityFileConfigLines = lib.concatMapStringsSep
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
    serverAliveCountMax = 5;
    serverAliveInterval = 60;

    extraConfig = ''
      IdentityAgent /run/user/1000/gnupg/S.gpg-agent.ssh
      ChallengeResponseAuthentication no
      AddKeysToAgent yes
      StrictHostKeyChecking ask
      VerifyHostKeyDNS yes
      StreamLocalBindUnlink yes
      Compression yes
      ${identityFileConfigLines}
    '';

    extraOptionOverrides = {
      ForwardX11 = "no";
      ForwardX11Trusted = "no";
      IdentitiesOnly = "yes";
    };

    matchBlocks = {
      "uptermd.upterm.dev" = {
        extraOptions = {
          PubkeyAcceptedAlgorithms = "+ssh-rsa";
          PubkeyAcceptedKeyTypes = "+ssh-rsa";
          HostKeyAlgorithms = "+ssh-rsa";
        };
      };
      "github.com" = {
        identityFile = map genYubikeyPubKeyPath yubikeyModels;
        user = "git";
        extraOptions = {
          ControlMaster = "no";
        };
      };
    } // builtins.listToAttrs (
      map
        (name: {
          inherit name;
          value = {
            forwardAgent = true;
            remoteForwards = [
              {
                # local
                host.address = "/run/user/1000/gnupg/S.gpg-agent.extra";
                # remote
                bind.address = "/run/user/1000/gnupg/S.gpg-agent";
              }
              {
                host.address = "/run/user/1000/gnupg/S.gpg-agent.ssh";
                bind.address = "/run/user/1000/gnupg/S.gpg-agent.ssh";
              }
            ];
            extraOptions = {
              ConnectTimeout = "15";
              StreamLocalBindUnlink = "yes";
            };
          };
        })
        (pkgs.notThisSystem hostName)
    );
  };
}
