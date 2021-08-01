{ config, lib, pkgs, ... }:
with lib;
let
  cfg = config.services.tailscale-up;
  tailscaleUp = pkgs.writeShellScriptBin "tailscale-up" ''
    ${cfg.package}/bin/tailscale up --authkey "$(${pkgs.coreutils}/bin/cat ${cfg.authKeyFile})"
  '';
  tailscaleDown = pkgs.writeShellScriptBin "tailscale-down" ''
    ${cfg.package}/bin/tailscale logout
  '';
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
