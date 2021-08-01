let
  sources = import ./nix;
  nixus = import sources.nixus { };
  inherit (sources) nixpkgs;
  systems = [
    "pigeon"
    "plover"
    "albatross"
    "falcon"
    "bluejay"
    "weebill"
  ];
  hostAttrList = map
    (name: {
      inherit name;
      value = { ... }: {
        host = name;
        configuration = ./systems + "/${name}.nix";
      };
    })
    systems;
in
nixus {
  defaults = { ... }: { inherit nixpkgs; };
  nodes = builtins.listToAttrs hostAttrList;
}
