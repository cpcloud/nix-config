self: super: {
  fail2ban = super.fail2ban.overrideAttrs (attrs: {
    patches = attrs.patches or [ ] ++ [
      (self.fetchpatch {
        url = "https://github.com/fail2ban/fail2ban/commit/294ec73f629d0e29cece3a1eb5dd60b6fccea41f.patch";
        sha256 = "sha256-Eimm4xjBDYNn5QdTyMqGgT5EXsZdd/txxcWJojXlsFE=";
      })
    ];
  });

  # patch until https://github.com/NixOS/nixpkgs/pull/178770 is merged and in unstable-small
  python310 = super.python310.override {
    packageOverrides = _: pysuper: {
      systemd = pysuper.systemd.overrideAttrs (attrs: {
        patches = attrs.patches or [ ] ++ [
          # Fix runtime issues on Python 3.10
          # https://github.com/systemd/python-systemd/issues/107
          (self.fetchpatch {
            url = "https://github.com/systemd/python-systemd/commit/c71bbac357f0ac722e1bcb2edfa925b68cca23c9.patch";
            sha256 = "sha256-22s72Wa/BCwNNvwbxEUh58jhHlbA00SNwNVchVDovcc=";
          })
        ];
      });
    };
  };
}
