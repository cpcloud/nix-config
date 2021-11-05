{ ... }:
let
  pairs = {
    "http://nix-community.cachix.org" = "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs=";
    "https://poetry2nix.cachix.org" = "poetry2nix.cachix.org-1:2EWcWDlH12X9H76hfi5KlVtHgOtLa1Xeb7KjTjaV/R8=";
    "https://cpcloud-nix-config.cachix.org" = "cpcloud-nix-config.cachix.org-1:1c6ZPYRACVNB3cYg9A+h9Xof8MKVVj3lYdye++RWSvo=";
    "https://nix-linter.cachix.org" = "nix-linter.cachix.org-1:BdTne5LEHQfIoJh4RsoVdgvqfObpyHO5L0SCjXFShlE=";
    "https://ibis.cachix.org" = "ibis.cachix.org-1:tKNWCdKmBXJFK1JE/SnA41z7U7XPFOnB7Nw0vLKXaLA=";
    "https://numbsql.cachix.org" = "numbsql.cachix.org-1:MMBbwgBZ+f+9EBvXX2ag3hVV4nRYm13UM3wGY11r81M=";
    "https://stupidb.cachix.org" = "stupidb.cachix.org-1:iJ5Je/opEa7W23qm2CWj2s0XHK2sb8Cb8INKASK0lbY=";
    "s3://compute-sdk-nix-cache?region=us-east-2" = "compute-sdk-nix-cache:zHWclDC0BAIuBM98fI6jRhWZYst//PNe53Q/khhYdyc=";
  };
in
{
  nix = {
    binaryCaches = builtins.attrNames pairs;
    binaryCachePublicKeys = builtins.attrValues pairs;
  };
}
