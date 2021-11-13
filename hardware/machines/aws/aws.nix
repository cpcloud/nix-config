{ modulesPath
, lib
, ...
}: {
  imports = [
    "${toString modulesPath}/../maintainers/scripts/ec2/amazon-image.nix"
    ../../hardware.nix
  ];

  amazonImage = {
    sizeMB = 10 * 1024;
    format = "vpc"; # this is called VHD in the AWS API
  };

  networking = {
    useNetworkd = lib.mkForce false;
    interfaces.eth0.useDHCP = true;
  };

  services.ssm-agent.enable = true;

  powerManagement.cpuFreqGovernor = lib.mkDefault "performance";

  nixpkgs.localSystem.system = "x86_64-linux";

  services = {
    fstrim.enable = true;
    fwupd.enable = true;
  };

  services.xserver.enable = false;
}
