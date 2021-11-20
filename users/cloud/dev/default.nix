{ pkgs, ... }: {
  home = {
    extraOutputsToInstall = [ "doc" "info" "devdoc" ];

    packages = (with pkgs; [
      ctags
      nixpkgs-fmt
      shfmt
      tmate
      tokei
      gdb
    ]);

    file.gdbinit = {
      target = ".gdbinit";
      source = ./gdbinit;
    };
  };
}
