{ pkgs, ... }: {
  home = {
    packages = with pkgs; [
      awscli2
    ];

    sessionVariables = {
      AWS_PROFILE = "vice";
    };
  };
}
