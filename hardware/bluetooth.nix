{ pkgs, ... }: {
  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
    disabledPlugins = [ "sap" ];
    settings = {
      General = {
        FastConnectable = "true";
        JustWorksRepairing = "always";
        MultiProfile = "multiple";
        IdleTimeout = 0;
      };
    };
  };

  services = {
    blueman.enable = true;
    dbus.packages = [ pkgs.blueman ];
  };
}
