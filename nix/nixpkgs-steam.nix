let
  sources = import ./.;
in
import sources.nixpkgs-steam { }
