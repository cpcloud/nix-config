{ ... }: {
  programs.starship = {
    enable = true;
    settings = {
      add_newline = false;

      git_status = {
        disabled = true;
      };

      directory.truncation_symbol = "…/";
    };
  };
}
