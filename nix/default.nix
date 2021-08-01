let
  sources = import ./sources.nix;
in
sources // {
  home-manager = "${sources.home-manager}/nixos";
}
