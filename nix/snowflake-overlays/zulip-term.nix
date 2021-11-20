{ config, ... }:
self: super: {
  zulip-term = self.writeShellApplication {
    name = "zterm";
    runtimeInputs = [ super.zulip-term ];
    text = ''
      zulip-term --config-file ${config.sops.secrets.ursalabs-zulip.path} "$@"
    '';
  };
}
