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
      inherit (hosts.${hostname}) localSystem;
      inherit (deploy-rs.lib.${localSystem}) activate;
    in
    {
      inherit hostname;
      profiles.system.path = activate.nixos nixosCfg;
    };
in
{
  autoRollback = true;
  magicRollback = true;
  user = "root";
  nodes = lib.mapAttrs genNode self.nixosConfigurations;
}
