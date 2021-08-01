{ pkgs, ... }: {
  # TODO: actually understand why allows the rr debugger to be fast
  boot.kernel.sysctl."kernel.perf_event_paranoid" = 1;

  environment.systemPackages = with pkgs; [
    linuxPackages.perf
  ];
}
