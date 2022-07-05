_: _: {
  # penalize cloud hosts by a somewhat arbitrary %25
  getSpeedFactor = { builderCores, hostCores, isCloudHost }:
    let
      hostCores = if isCloudHost then (builderCores / 4.0) * 3.0 else builderCores;
    in
    builtins.floor (builderCores / hostCores);
}
