{ pkgs, lib, ... }: {
  home = {
    extraOutputsToInstall = [ "doc" "info" "devdoc" ];
    packages = (with pkgs; [
      ctags
      nixpkgs-fmt
      shfmt
      tmate
      tokei
      gdb
    ]) ++ (lib.optionals (!pkgs.stdenv.isAarch64) (with pkgs; [
      google-cloud-sdk
      shellcheck
    ]));

    file.gdbinit = {
      target = ".gdbinit";
      source = ./gdbinit;
    };
  };
}
