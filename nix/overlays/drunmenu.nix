let
  drunmenu =
    { spawn
    , writeShellApplication
    , displayCmd
    , extraInputs ? [ ]
    }:
    writeShellApplication {
      name = "drunmenu";
      runtimeInputs = [ spawn ] ++ extraInputs;
      text = ''
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
