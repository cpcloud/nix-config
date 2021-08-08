let
  sources = import ../nix;
  pkgs = import sources.nixpkgs { };
in
pkgs.mkShell {
  name = "repo-commits";
  buildInputs = (with pkgs; [
    nodejs
  ]) ++ (with pkgs.nodePackages; [
    npm
    typescript
    eslint
  ]);

  # npm forces output that can't possibly be useful to stdout so redirect
  # stdout to stderr
  shellHook = ''
    npm install --no-fund 1>&2
  '';
}
