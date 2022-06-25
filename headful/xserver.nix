_: {
  services = {
    xserver = {
      enable = true;
      layout = "us";
      autorun = true;
      desktopManager.xterm.enable = false;

      # Caps lock is a useless turd
      xkbOptions = "ctrl:nocaps,altwin:swap_lalt_lwin";

      # Enable touchpad support.
      libinput = {
        enable = true;
        # disable tap to click
        touchpad.tapping = false;
      };
    };
  };
}
