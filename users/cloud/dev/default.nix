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

    file.gdbinit = {
      target = ".gdbinit";
      source = ./gdbinit;
    };
  };
}
