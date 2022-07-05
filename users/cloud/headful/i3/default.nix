{ config, lib, pkgs, ... }: {
  imports = [
    ./alacritty.nix
    ./polybar.nix
    ./rofi.nix
  ];

  xsession.windowManager.i3 = {
    enable = true;
    config = rec {
      bars = [ ];
      startup = [
        {
          command = ''
            ${pkgs.systemd}/bin/systemctl --user import-environment; \
              ${pkgs.systemd}/bin/systemctl --user import-environment DISPLAY; \
              ${pkgs.systemd}/bin/systemctl --user start i3-session.target
          '';
          always = false;
          notification = false;
        }
        {
          command = "${pkgs.systemd}/bin/systemctl --user restart polybar";
          always = true;
          notification = false;
        }
        {
          command = "${pkgs.xorg.xset}/bin/xset r rate 200 30";
          always = true;
          notification = false;
        }
        {
          command = "${pkgs.xorg.xset}/bin/xset -dpms";
          always = true;
          notification = false;
        }
        {
          command = "${pkgs.xorg.xset}/bin/xset s off";
          always = true;
          notification = false;
        }
        {
          command = "${pkgs.xorg.setxkbmap}/bin/setxkbmap -option ctrl:nocaps -option altwin:swap_lalt_lwin";
          always = true;
          notification = false;
        }
      ];
      modifier = "Mod4";
      terminal = "${config.programs.alacritty.package}/bin/alacritty";
      keybindings =
        let
          execSpawn = cmd: "exec ${cmd}";
          exec = cmd: "exec ${cmd}";
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
          "XF86MonBrightnessUp" = exec "brightnessctl set +10%";
          "XF86MonBrightnessDown" = exec "brightnessctl set 10%-";
          "XF86VolumeUp" = exec "pactl set-sink-volume @DEFAULT_SINK@ +5%";
          "XF86VolumeDown" = exec "pactl set-sink-volume @DEFAULT_SINK@ -5%";
          "XF86Mute" = exec "pactl set-sink-mute @DEFAULT_SINK@ toggle";
          "${modifier}+Shift+Return" = execSpawn terminal;
          "${modifier}+Return" = execSpawn terminal-with-tmux;
          "${modifier}+c" = execSpawn "brave";
          "${modifier}+Shift+c" = execSpawn "brave --incognito";
          "${modifier}+Shift+r" = "reload";
          "${modifier}+d" = execSpawn "${pkgs.drunmenu-x11}/bin/drunmenu";
          "${modifier}+m" = execSpawn "${pkgs.emojimenu-x11}/bin/emojimenu";
          "${modifier}+Shift+i" = exec "i3lock";

          "${modifier}+x" = exec screenshotWindowCmd;
          "${modifier}+Shift+x" = exec screenshotAndClipCmd;

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
