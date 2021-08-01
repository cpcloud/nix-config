{ config }:
self: super: {
  gh = self.writeShellScriptBin "gh" ''
    GITHUB_TOKEN="$(cat ${config.sops.secrets.github_gh_token.path})" \
     ${super.gh}/bin/gh "$@"
  '';
}
