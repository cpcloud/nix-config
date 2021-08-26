{ config, lib, pkgs, ... }:
with lib;
let
  cfg = config.services.tailscale-up;
  tailscaleUp = pkgs.writeSaneShellScriptBin {
    name = "tailscale-up";
    buildInputs = [ pkgs.coreutils cfg.package ];
    src = ''
      tailscale up --authkey "$(cat ${cfg.authKeyFile})"
    '';
  };
  tailscaleDown = pkgs.writeSaneShellScriptBin {
    name = "tailscale-down";
    buildInputs = [ cfg.package ];
    src = "tailscale logout";
  };
in
{
  options.services.tailscale-up = {
    enable = mkEnableOption "tailscale-up";

    package = mkOption {
      type = types.package;
      default = pkgs.tailscale;
      defaultText = "pkgs.tailscale";
      description = "The tailscale package that should be used to run tailscale-up.";
    };

    authKeyFile = mkOption {
      type = types.path;
      description = "A path to a file containing an authkey for tailscale.";
    };
  };

  config = mkIf cfg.enable {
    systemd.services = {
      tailscale-up = {
        wantedBy = [ "multi-user.target" ];
        requires = [ "tailscaled.service" ];
        after = [ "tailscaled.service" ];

        serviceConfig = {
          ExecStart = "${tailscaleUp}/bin/tailscale-up";
          ExecStop = "${tailscaleDown}/bin/tailscale-down";
          Type = "oneshot";
          SupplementaryGroups = [ config.users.groups.keys.name ];
          RemainAfterExit = true;
        };
      };
    };
  };
}
