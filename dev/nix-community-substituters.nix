let
  pairs = {
    "http://nix-community.cachix.org" = "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs=";
    "https://cpcloud-nix-config.cachix.org" = "cpcloud-nix-config.cachix.org-1:1c6ZPYRACVNB3cYg9A+h9Xof8MKVVj3lYdye++RWSvo=";
    "https://ibis.cachix.org" = "ibis.cachix.org-1:tKNWCdKmBXJFK1JE/SnA41z7U7XPFOnB7Nw0vLKXaLA=";
    "https://nix-linter.cachix.org" = "nix-linter.cachix.org-1:BdTne5LEHQfIoJh4RsoVdgvqfObpyHO5L0SCjXFShlE=";
    "https://numbsql.cachix.org" = "numbsql.cachix.org-1:MMBbwgBZ+f+9EBvXX2ag3hVV4nRYm13UM3wGY11r81M=";
    "https://poetry2nix.cachix.org" = "poetry2nix.cachix.org-1:2EWcWDlH12X9H76hfi5KlVtHgOtLa1Xeb7KjTjaV/R8=";
    "https://protoletariat.cachix.org" = "protoletariat.cachix.org-1:YGBjQ/CTTxKjuPOYG/bON4vj6EWycyJQlY0CJBkcbcw=";
    "https://stupidb.cachix.org" = "stupidb.cachix.org-1:iJ5Je/opEa7W23qm2CWj2s0XHK2sb8Cb8INKASK0lbY=";
    "https://minesweep.cachix.org" = "minesweep.cachix.org-1:8ldlvDtrH4acflgG2B7t3RunnRpF1VYa10nl4XlbKmc=";
    "https://ibis-substrait.cachix.org" = "ibis-substrait.cachix.org-1:9QMhfByEHEl46s4tqVcRiyiOct2bnmZ23BJk4NTgGGI=";
  };
in
{
  nix.settings = {
    substituters = builtins.attrNames pairs;
    trusted-public-keys = builtins.attrValues pairs;
  };
}
