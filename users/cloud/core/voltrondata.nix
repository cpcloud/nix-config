{ pkgs, ... }: {
  home.packages = with pkgs; [
    awscli2
    google-cloud-sdk
    docker-credential-gcr
    amazon-ecr-credential-helper
    ssm-session-manager-plugin
  ];
}
