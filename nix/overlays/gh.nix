{ config, ... }:
self: super: {
  gh = self.writeSaneShellScriptBin {
    name = "gh";
    buildInputs = [ super.gh self.coreutils ];
    src = ''
      GITHUB_TOKEN="$(cat ${config.sops.secrets.github-gh-token.path})" \
      ${super.gh}/bin/gh "$@"
    '';
  };
}
