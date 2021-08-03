let
  drunmenu =
    { spawn
    , writeSaneShellScriptBin

    , displayCmd
    , extraInputs ? [ ]
    }:
    writeSaneShellScriptBin {
      name = "drunmenu";

      buildInputs = [ spawn ] ++ extraInputs;

      src = ''
        program="$(${displayCmd})"
        exec spawn "$program"
      '';
    };
in
self: _: {

  drunmenu-x11 = self.callPackage drunmenu {
    displayCmd = ''
      rofi \
        -cache-dir "$XDG_CACHE_HOME/rofi/drunmenu" \
        -run-command "echo {cmd}" \
        -show drun
    '';
    extraInputs = with self; [ rofi ];
  };
}
