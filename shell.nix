let
  sources = import ./nix;
  pkgs = import sources.nixpkgs {
    overlays = [
      (import ./overlays/write-sane-shell-script-bin.nix)
    ];
  };
  lib = pkgs.lib;
  sops-nix = pkgs.callPackage sources.sops-nix { };
  prettier = pkgs.writeSaneShellScriptBin {
    name = "prettier";
    src = ''
      ${pkgs.nodePackages.prettier}/bin/prettier \
      --plugin-search-dir "${pkgs.nodePackages.prettier-plugin-toml}/lib" \
      "$@"
    '';
  };
  styluaSettings = builtins.fromTOML (
    lib.replaceStrings [ "_" ] [ "-" ] (lib.readFile ./stylua.toml)
  );
  styluaSettingsArgs = lib.concatStringsSep
    " "
    (lib.mapAttrsToList (name: value: "--${name}=${toString value}") styluaSettings);
  styluaWithFormat = pkgs.writeSaneShellScriptBin {
    name = "stylua";
    src = ''${pkgs.stylua}/bin/stylua ${styluaSettingsArgs} "$@"'';
  };
in
pkgs.mkShell {
  name = "nix-config";
  nativeBuildInputs = [ sops-nix.sops-import-keys-hook ];
  buildInputs = (with pkgs; [
    cryptsetup
    git
    gnupg
    jq
    niv
    nix-linter
    nixpkgs-fmt
    shellcheck
    shfmt
    sops
    srm
    ssh-to-pgp
    styluaWithFormat
    yj
  ]) ++ [ prettier pkgs.nodePackages.eslint ];

  shellHook = ''
    ${(import ./pre-commit.nix).pre-commit-check.shellHook}
  '';

  sopsPGPKeyDirs = [
    "./keys/hosts"
    "./keys/users"
  ];

  SOPS_GPG_KEYSERVER = "https://keys.openpgp.org";
}
