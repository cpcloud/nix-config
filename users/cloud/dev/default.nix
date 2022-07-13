{ pkgs, ... }: {
  home = {
    extraOutputsToInstall = [ "doc" "info" "devdoc" ];

    packages = with pkgs; [
      ctags
      gdb
      nixpkgs-fmt
      shfmt
      tokei
      upterm
    ];

    file.gdbinit =
      let
        src = pkgs.fetchFromGitHub {
          owner = "cyrus-and";
          repo = "gdb-dashboard";
          rev = "v0.16.0";
          sha256 = "sha256-sk638bMM96Nuv+tcNsJANhj6EOaqjN8CRmG8kvFEceY=";
        };
      in
      rec {
        target = ".gdbinit";
        source = src + "/${target}";
      };
  };
}
