{
  home.file.".ssh/config".text = ''
    Host github.com
        ControlMaster no
        IdentitiesOnly yes
        IdentityAgent /run/user/1000/gnupg/S.gpg-agent.ssh
        IdentityFile ~/.ssh/id_rsa_yubikey_5_nano.pub
        IdentityFile ~/.ssh/id_rsa_yubikey_5_nfc.pub
        IdentityFile ~/.ssh/id_rsa_yubikey_5c_nano.pub
        User git
    Host *
        AddKeysToAgent yes
        ChallengeResponseAuthentication no
        ControlMaster auto
        ControlPath ~/.ssh/a-%C
        ControlPersist 30m
        ForwardAgent no
        ForwardX11 no
        ForwardX11Trusted no
        HashKnownHosts yes
        IdentitiesOnly yes
        IdentityAgent /run/user/1000/gnupg/S.gpg-agent.ssh
        IdentityFile ~/.ssh/id_rsa_yubikey_5_nano.pub
        IdentityFile ~/.ssh/id_rsa_yubikey_5_nfc.pub
        IdentityFile ~/.ssh/id_rsa_yubikey_5c_nano.pub
        ServerAliveCountMax 5
        ServerAliveInterval 60
        StrictHostKeyChecking ask
        VerifyHostKeyDNS yes
  '';
}
