{ config }:
self: super: {
  zulip-term = self.writeSaneShellScriptBin {
    name = "zterm";
    buildInputs = [ super.zulip-term ];
    src = ''
      ${super.zulip-term}/bin/zulip-term --config-file ${config.sops.secrets.ursalabs-zulip.path} "$@"
    '';
  };
}
