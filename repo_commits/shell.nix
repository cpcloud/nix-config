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

  shellHook = ''
    npm install --no-fund
  '';
}
