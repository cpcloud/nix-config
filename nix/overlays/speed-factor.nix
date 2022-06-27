_: _: {
  # penalize cloud hosts by a somewhat arbitrary %25
  getSpeedFactor = { maxJobs, config, isCloudHost ? false }: (
    if isCloudHost then (maxJobs / 4) * 3 else maxJobs
  ) / config.nix.settings.max-jobs;
}
