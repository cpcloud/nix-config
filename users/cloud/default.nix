{ config, lib, pkgs, ... }: {
  # for coral edgetpus
  users.groups.plugdev.members = [ "cloud" ];

  users.users.cloud = {
    isNormalUser = true;
    createHome = true;
    description = "Phillip Cloud";

    extraGroups = [ "wheel" "dialout" "video" config.users.groups.keys.name ]
      ++ lib.optionals config.networking.networkmanager.enable [ "networkmanager" ]
      ++ lib.optionals config.programs.wireshark.enable [ "wireshark" ]
      ++ lib.optionals config.virtualisation.docker.enable [ "docker" ]
      ++ lib.optionals config.virtualisation.virtualbox.host.enable [ "vboxsf" "vboxusers" ];

    shell = lib.mkIf config.programs.zsh.enable pkgs.zsh;
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICfPRiesz2VviTkRJAd3mzGRm2P+K67SutblfJ9I1+rU cloud@standard.ai"
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCZw84Dwn4QN0l+EBXkzYHRzcmKLeEULODoJuWdVvQt96u/YWquk5iVsJUwRzioQoRT+KDr4CNBPTbW/hghHvnyjowksnMU9vrhVr6ZoEOzjuXiydc/bTy2yL/kORuCdSKYPZTuXJ85Ixz7Ka5c953Jqr8H59P6vbZFMHy6ASNyq8qOUj5C/tdjxPDxnLOaL3rX4r+hAsTP6gIIcADuAnSUxIXSZdFFLbJEAXZzqOYUXYf48BB8tdxPH/Y5j4Odcr3pHawslKRSDjrlo3kTaGmRRuqneS+Uxrti/a9/1ReXKHU7oqb+SjizkxTBswJ1JMGaWiK9rFdciDEig0f8RY6FnPo0ooGaK23Wk//E3UynTcBMr30WcadgADuYjZAldPNG3HtwEBct0miwYw4TXJoVnTR7R9tTN01g4r4gwZqBqe5g8FNUIMN2xrQjOmRLhL9Y6Ky/g+tvXtqrlHndIObSfe/VxsM5Qc1lhGhbQy79n7o31zxXmn9KCn2DmoT+iuE= cloud@albatross"
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQC5ZiXnzZQQXlr+DC43IHal2kVgfqGFMIKnTMgiFmfPCuEfDteHS76mlPVWOkzoN+HQ6QhJgmosHOj0+GBN808bvuZ/W/hHvwRDG3jD6j7OXrqtMGTsVcwlrZD3hXF+/8N8NaIUGX3NxBrjSAgV5HdPdiscrNeCCkba8eWYbkxFc6cmJYj0CD19UdX++m3fVE9I5H5Ccc8QC9uFks7kJItFFY/SHisZS9GgBboz3OeGzV5fPZcoleRV4gWPVjDQSLC3PIroyI3hqDTt08+yxec8M7DT8DkJso6JCyvOjZe4thJau7if2LxS0eq5SblJ7WcS+BzYOSbKC3ykBqIJIpTAgASO/3oxyRzMgoUDnztliUVwoCLOj7ie3vW1Eb4rCJbPa73wkIecKVRjrfrK8zynIvsIBQsxsIyjVSWZ6WLZHd7CeqMs+SZwUlZqHB4Hkr70smmp7quZkoXSBeFJgKvtU59SpEU1W6XezjuR8W4YbF29auFS1CV093tMMiQgH9E= cloud@pigeon"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMnPFaBQzvDPdzI51qXbVYAucnXvnFsiM43eiuWNfV6k ***REMOVED***"
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCrngj/2Z0Ne+qVTJELSuHvr6XxNSiJ6V1da8LGY//oYP7SnMy0V1GoSwqdfvFF8l+lRfruVEBzky9H6m1ise+DUSBIUVC+rWB9dkiqYimbsLDgyZig+Pk0aATB7wYYUb5rjvWNzAJx61R7/YV8L8IMVsgX/yzJbPV9NPD840VgrV83YjPclzc9RC70a0hKKQ7Z2w8aLmGAVK8fZ7cibMI0HjjjcnhK3lVu0d0aKL14+VcGclpmQoSsP8DP6NGLdsRlwELDVgO+HlnW63iYTDeb1wiVDslwLxsfGONyZ3LJvEhhELohxLyRPr6QFC5CPjG9rtR9dm9wANM9/Qv0r1K3b3ULuju2XTB1s3dvWSMxCvlTc3YA/e1KWxDS4a9IRi7ZVyyypX/BZtSATafIcXD0QMsA4+/slDdd7ME1+X9OGRjJf1GdlsmlNAwv094SAJzZ6t8CWfs22bsGxMLQvJTT7C2BvrZWlys3XhRcsC8fJkP+AOqoeMRbjVERPz4Rr5c= cloud@bluejay"
    ];
  };

  sops.secrets.github_token = {
    sopsFile = ../../secrets/github.token.yaml;
    owner = "cloud";
  };

  sops.secrets.github_gh_token = {
    sopsFile = ../../secrets/github.gh.token.yaml;
    owner = "cloud";
  };

  sops.secrets.cargo_token = {
    sopsFile = ../../secrets/cargo.token.yaml;
    owner = "cloud";
  };

  home-manager.users.cloud =
    { ... }: {
      imports = [
        ./core
        ./dev
      ] ++ lib.optionals config.services.xserver.enable [
        ./headful
      ] ++ lib.optionals config.programs.gnupg.agent.enable [
        ./trusted
      ];

      home.packages = lib.optionals config.virtualisation.docker.enable (with pkgs; [
        docker-credential-helpers
        docker-credential-gcr
      ]);

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
