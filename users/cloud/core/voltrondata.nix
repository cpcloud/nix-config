{ pkgs, ... }: {
  home.packages = with pkgs; [
    google-cloud-sdk
    docker-credential-gcr
    amazon-ecr-credential-helper
    ssm-session-manager-plugin
  ];
}
