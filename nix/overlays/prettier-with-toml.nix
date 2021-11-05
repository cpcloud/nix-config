{ ... }:
self: _: {
  prettierWithToml = self.writeShellScriptBin "prettier" ''
    set -euo pipefail

    ${self.nodePackages.prettier}/bin/prettier \
    --plugin-search-dir "${self.nodePackages.prettier-plugin-toml}/lib" \
    "$@"
  '';
}
