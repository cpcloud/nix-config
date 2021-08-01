self: super: super.lib.optionalAttrs super.stdenv.isAarch64 {
  exa = super.exa.overrideAttrs (old: {
    nativeBuildInputs = super.lib.remove self.pandoc old.nativeBuildInputs;
    outputs = [ "out" ];
    postInstall = ''
      installShellCompletion \
      --name exa completions/completions.bash \
      --name exa.fish completions/completions.fish \
      --name _exa completions/completions.zsh
    '';
  });
}
