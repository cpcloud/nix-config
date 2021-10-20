let
  sources = import ./nix;
  nixus = import sources.nixus { };
  inherit (sources) nixpkgs;
  systems = [
    "albatross"
    "bluejay"
    "falcon"
    "plover"
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
