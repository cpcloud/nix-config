{
  home.file.".ssh/config".text = ''
    Host github.com
        ControlMaster auto
        IdentityFile ~/.ssh/id_rsa_yubikey.pub
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
        ServerAliveCountMax 5
        ServerAliveInterval 60
        StrictHostKeyChecking ask
        VerifyHostKeyDNS yes
  '';
}
