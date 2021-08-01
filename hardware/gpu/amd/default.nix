{ pkgs, ... }: {
  environment.systemPackages = with pkgs; [
    rocm-smi
    radeontop
  ];

  hardware.opengl = {
    enable = true;
    driSupport = true;
    extraPackages = with pkgs; [
      rocm-opencl-icd
      rocm-opencl-runtime
    ];
  };
}
