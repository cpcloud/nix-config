{ pkgs, ... }: rec {
  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
    settings = {
      General = {
        FastConnectable = "true";
        JustWorksRepairing = "always";
        MultiProfile = "multiple";
      };
    };
  };

  services = {
    blueman.enable = true;
    dbus.packages = [ pkgs.blueman ];
  };

  # XXX: Due to how .serviceConfig is an option and .ExecStart is technically
  # a list, you will add multiple ExecStart='s to the .service file, and this
  # not a nixos option, you cant use things like mkForce on it. If you set it to
  # one. The empty one is a signal to systemd, to ignore the original copy
  # will cause it to have 3 entries, the original, an empty, and the new
  systemd.services.bluetooth.serviceConfig.ExecStart =
    [ "" "${hardware.bluetooth.package}/libexec/bluetooth/bluetoothd --noplugin=sap" ];

  hardware.pulseaudio = {
    package = pkgs.pulseaudio.override { bluetoothSupport = true; };
    extraConfig = ''
      load-module module-switch-on-connect
      load-module module-bluetooth-discover a2dp_config="ldac_eqmid=hq ldac_fmt=f32"
      load-module module-bluetooth-policy
    '';
    extraModules = [ pkgs.pulseaudio-modules-bt ];
  };
}
