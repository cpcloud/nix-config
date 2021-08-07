let
  sources = import ./nix;
  pkgs = import sources.nixpkgs { };
  pythonEnv = pkgs.python3.withPackages (p: with p; [
    click
    requests
  ]);
in
pkgs.mkShell {
  name = "repo-commits";
  buildInputs = [
    pkgs.cacert
    pythonEnv
  ];
}
