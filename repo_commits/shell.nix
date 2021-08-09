let
  sources = import ../nix;
  pkgs = import sources.nixpkgs { };
in
pkgs.mkShell {
  name = "repo-commits";
  buildInputs = (with pkgs; [ nodejs yarn ]);

  # npm forces output that can't possibly be useful to stdout so redirect
  # stdout to stderr
  shellHook = ''
    yarn install 1>&2
  '';
}
