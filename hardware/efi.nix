{ ... }: {
  console.earlySetup = true;
  boot = {
    # Use the systemd-boot EFI boot loader.
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };
    tmpOnTmpfs = true;
  };
}
