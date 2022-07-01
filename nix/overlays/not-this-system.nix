self: _: {
  notThisSystem = hostName: builtins.filter
    (name: name != hostName)
    (map (self.lib.removeSuffix ".nix") (self.lib.attrNames (builtins.readDir ../../hosts)));
}
