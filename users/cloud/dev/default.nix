{ pkgs, ... }: {
  home = {
    extraOutputsToInstall = [ "doc" "info" "devdoc" ];

    packages = with pkgs; [
      ctags
      gdb
      nixpkgs-fmt
      shfmt
      tmate
      tokei
    ];

    file.gdbinit = {
      target = ".gdbinit";
      source = ./gdbinit;
    };
  };
}
