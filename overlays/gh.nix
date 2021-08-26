{ config }:
self: super: {
  gh = self.writeSaneShellScriptBin {
    name = "gh";
    buildInputs = [ super.gh self.coreutils ];
    src = ''
      GITHUB_TOKEN="$(cat ${config.sops.secrets.github_gh_token.path})" \
      ${super.gh}/bin/gh "$@"
    '';
  };
}
