_: _: {
  # penalize cloud hosts by a somewhat arbitrary %25
  getSpeedFactor = { builderCores, hostCores, isCloudHost }:
    let
      adjustedBuilderCores = if isCloudHost then builderCores * 0.75 else builderCores;
    in
    builtins.floor (adjustedBuilderCores / hostCores);
}
