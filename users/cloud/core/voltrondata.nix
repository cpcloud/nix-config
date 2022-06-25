{ pkgs, lib, ... }: {
  home.packages = with pkgs; [
    awscli2
    google-cloud-sdk
    docker-credential-gcr
    amazon-ecr-credential-helper
  ] ++ lib.optionals (!pkgs.stdenv.isAarch64) [
    ssm-session-manager-plugin
  ];
}
