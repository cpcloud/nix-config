{ pkgs, ... }: {
  home.packages = with pkgs; [
    awscli2
    amazon-ecr-credential-helper
    ssm-session-manager-plugin
  ];
}
