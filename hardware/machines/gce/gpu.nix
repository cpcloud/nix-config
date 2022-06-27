{
  imports = [
    ../../gpu/nvidia/basic.nix
    ./gce.nix
  ];

  services.xserver.videoDrivers = [ "nvidia" ];
}
