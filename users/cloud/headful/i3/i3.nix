{ config, lib, pkgs, ... }: {
  xsession.windowManager.i3 = {
    enable = true;
    config = rec {
      bars = [ ];
      startup = [
        { command = "systemctl --user start gnome-keyring"; }
        {
          command = "systemctl --user start i3-session.target";
          always = false;
          notification = false;
        }
        { command = "${pkgs.autorandr}/bin/autorandr --load desktop"; }
        { command = "exec xset r rate 200 30"; }
      ];
      modifier = "Mod4";
      terminal = "${config.programs.alacritty.package}/bin/alacritty";
      keybindings =
        let
          terminal-with-tmux = "${terminal} -e tmux";
          screenshotWindowCmd = pkgs.writeShellScript "screenshot" ''
            set -euo pipefail

            ${pkgs.coreutils}/bin/mkdir -p "$HOME/screenshots"
            ${pkgs.coreutils}/bin/sleep 0.2
            timestamp="$(${pkgs.coreutils}/bin/date --iso-8601=ns | ${pkgs.coreutils}/bin/tr ',:' '.')"
            ${pkgs.scrot}/bin/scrot --focused "$HOME/screenshots/''${timestamp}.png"
          '';
          screenshotAndClipCmd = pkgs.writeShellScript "screenshot" ''
            set -euo pipefail

            ${pkgs.coreutils}/bin/sleep 0.2
            ${pkgs.scrot}/bin/scrot -s -o /dev/stdout | ${pkgs.xclip}/bin/xclip -selection clipboard -t image/png
          '';
          numWorkspaces = 10;
          nums = map toString (builtins.genList lib.id numWorkspaces);
        in
        lib.mkOptionDefault ({
          "${modifier}+Shift+Return" = "exec ${terminal}";
          "${modifier}+Return" = "exec ${terminal-with-tmux}";
          "${modifier}+c" = "exec brave";
          "${modifier}+Shift+c" = "exec brave --incognito";
          "${modifier}+Shift+r" = "reload";
          "${modifier}+d" = "exec rofi -show combi";
          "${modifier}+Shift+i" = "exec i3lock";

          "${modifier}+x" = "exec ${screenshotWindowCmd}";
          "${modifier}+Shift+x" = "exec ${screenshotAndClipCmd}";

          "${modifier}+h" = "focus left";
          "${modifier}+j" = "focus down";
          "${modifier}+k" = "focus up";
          "${modifier}+l" = "focus right";

          "${modifier}+Shift+h" = "move left";
          "${modifier}+Shift+j" = "move down";
          "${modifier}+Shift+k" = "move up";
          "${modifier}+Shift+l" = "move right";

          "${modifier}+n" = "workspace next";
          "${modifier}+p" = "workspace prev";
        } // (
          lib.listToAttrs
            (
              (map
                (num: {
                  name = "${modifier}+${num}";
                  value = "workspace ${num}";
                })
                nums) ++
              (map
                (num: {
                  name = "${modifier}+Shift+${num}";
                  value = "move container to workspace ${num}";
                })
                nums)
            )
        ));

      floating = {
        inherit modifier;
      };

      fonts = {
        names = [ "monospace" ];
        size = 10.0;
      };

      gaps = {
        inner = 3;
        outer = 3;
        smartBorders = "on";
        smartGaps = false;
      };

      focus = {
        followMouse = true;
        mouseWarping = false;
        newWindow = "smart";
      };

      window.border = 0;
    };
  };
}
