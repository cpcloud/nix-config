{
  services.udev.extraRules = builtins.readFile ./coral.rules;
}
