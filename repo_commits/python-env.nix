let
  sources = import ../nix;
  pkgs = import sources.nixpkgs { };
  pythonEnv = pkgs.python3.withPackages (p: [ p.requests ]);
in
pkgs.mkShell {
  name = "repo-commits";
  buildInputs = [
    pkgs.cacert
    pythonEnv
  ];
}
