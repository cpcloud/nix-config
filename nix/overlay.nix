{ deploy-rs
, nixpkgs
, sops-nix
, nix-index-database
, ...
}:

let
  inherit (nixpkgs.lib) composeManyExtensions;
  inherit (builtins) attrNames readDir;
  localOverlays = map
    (f: import (./overlays + "/${f}"))
    (attrNames (readDir ./overlays));
in
composeManyExtensions (localOverlays ++ [
  deploy-rs.overlay
  sops-nix.overlay
  (_: _: { nix-index-database = nix-index-database.legacyPackages.database; })
])
