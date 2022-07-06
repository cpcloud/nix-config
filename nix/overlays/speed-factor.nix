_: _: {
  # penalize cloud hosts by a somewhat arbitrary %25
  # penalize emulation by anothe arbitrary %50
  getSpeedFactor = { builderCores, hostCores, isCloudHost, usesEmulation }:
    let
      cloudHostPenalty = if isCloudHost then 0.25 else 0.0;
      emulationPenalty = if usesEmulation then 0.5 else 0.0;
      adjustedBuilderCores = builderCores * (1.0 - cloudHostPenalty) * (1.0 - emulationPenalty);
    in
    builtins.floor (adjustedBuilderCores / hostCores);
}
