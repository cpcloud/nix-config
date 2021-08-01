{ pkgs, ... }: {
  services = {
    xserver = {
      displayManager.defaultSession = "none+i3";
      windowManager.i3 = {
        enable = true;
        package = pkgs.i3-gaps;
        extraPackages = with pkgs; [
          i3lock
        ];
      };
    };
  };
}
