{ pkgs, ... }:
let
  json = pkgs.formats.json { };
in
{
  home.file.".config/docker.json".source = json.generate "docker.json" {
    credHelpers = {
      "734116910324.dkr.ecr.us-east-2.amazonaws.com" = "ecr-login";
      "public.ecr.aws" = "ecr-login";
    };
  };
}
