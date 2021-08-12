self: _: {
  writeSaneShellScriptBin = self.callPackage
    (
      { stdenv
      , writeTextFile
      , lib
      , shellcheck
      , runtimeShell
      }: (
        { name
        , src
        , buildInputs ? [ ]
        , checkPhase ? ""
        }: writeTextFile {
          inherit name;
          executable = true;
          destination = "/bin/${name}";
          text = ''
            #!${runtimeShell}
            set -e
            set -o errexit
            set -o nounset
            set -o pipefail
            export PATH="$PATH:${lib.makeBinPath buildInputs}"
            ${src}
          '';

          checkPhase = checkPhase + ''
            runHook preCheck
            ${stdenv.shell} -n $out/bin/${name}
            ${shellcheck}/bin/shellcheck $out/bin/${name}
            runHook postCheck
          '';
        }
      )
    )
    { };
}
