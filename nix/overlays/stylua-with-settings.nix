self: _: {
  styluaWithFormat =
    let
      styluaSettings = builtins.fromTOML (
        self.lib.replaceStrings [ "_" ] [ "-" ] (self.lib.readFile ../../stylua.toml)
      );
      styluaSettingsArgs = self.lib.concatStringsSep
        " "
        (self.lib.mapAttrsToList (name: value: "--${name}=${toString value}") styluaSettings);
    in
    self.writeShellScriptBin "stylua" ''
      set -euo pipefail

      ${self.stylua}/bin/stylua ${styluaSettingsArgs} "$@"
    '';
}
