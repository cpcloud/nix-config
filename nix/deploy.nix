{ self
, deploy-rs
, nixpkgs
, ...
}:
let
  inherit (nixpkgs) lib;
  hosts = (import ./hosts.nix).all;

  genNode = hostname: nixosCfg:
    let
      inherit (hosts.${hostname}) localSystem address;
      inherit (deploy-rs.lib.${localSystem}) activate;
    in
    {
      hostname = if address != null then address else hostname;
      profiles.system.path = activate.nixos nixosCfg;
    };
in
{
  autoRollback = true;
  magicRollback = true;
  user = "root";
  nodes = lib.mapAttrs genNode self.nixosConfigurations;
}
