pkgs: system:
{ deploy-rs, ... }@inputs:
let
  inherit (builtins) elemAt mapAttrs;
  inherit (pkgs.lib) filterAttrs;

  mkHost = name: system: import ./mk-host.nix { inherit pkgs inputs name system; };

  mkPath = name: system: deploy-rs.lib.${system}.activate.nixos (mkHost name system);

  hosts = filterAttrs (_: v: v.system == system) (import ./hosts.nix);
in
{
  deploy = {
    autoRollback = true;
    magicRollback = true;
    user = "root";
    nodes = mapAttrs
      (n: v: {
        inherit (v) hostname;
        profiles.system.path = mkPath n v.system;
      })
      hosts;
  };
}
