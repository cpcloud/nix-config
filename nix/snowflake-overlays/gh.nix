config: self: super: {
  gh = self.writeShellApplication {
    name = "gh";
    runtimeInputs = [ super.gh self.coreutils ];
    text = ''
      GITHUB_TOKEN="$(cat ${config.sops.secrets.github-gh-token.path})" \
      ${super.gh}/bin/gh "$@"
    '';
  };
}
