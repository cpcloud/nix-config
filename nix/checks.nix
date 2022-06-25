{ self, pre-commit-hooks, ... }:

system:

with self.nixpkgs.${system};
{
  pre-commit-check = pre-commit-hooks.lib."${system}".run {
    src = lib.cleanSource ../.;
    hooks = {
      nix-linter.enable = true;
      nixpkgs-fmt.enable = true;
      statix.enable = true;

      luacheck = {
        enable = true;
        types = [ "file" "lua" ];
        entry = "${luajitPackages.luacheck}/bin/luacheck --std luajit --globals vim -- ";
      };

      actionlint = {
        enable = true;
        files = "^.github/workflows/";
        types = [ "yaml" ];
        entry = "${actionlint}/bin/actionlint";
      };

      eslint = {
        enable = true;
        entry = lib.mkForce "${nodePackages.eslint}/bin/eslint";
        types = [ "file" ];
        files = lib.mkForce "\\.ts$";
      };

      prettier = {
        enable = true;
        entry = lib.mkForce "${nodePackages.prettier}/bin/prettier --check";
        types_or = lib.mkForce [
          "javascript"
          "json"
          "markdown"
          "yaml"
        ];
      };

      prettier-ts = {
        enable = true;
        entry = lib.mkForce "${nodePackages.prettier}/bin/prettier --check";
        types = [ "file" ];
        files = "\\.ts$";
      };

      stylua = {
        enable = true;
        entry = lib.mkForce "${styluaWithFormat}/bin/stylua --check --verify";
        types = [ "file" ];
        files = "\\.lua$";
      };
    };
    settings.nix-linter.checks = [
      "DIYInherit"
      "EmptyInherit"
      "EmptyLet"
      "EtaReduce"
      "LetInInheritRecset"
      "ListLiteralConcat"
      "NegateAtom"
      "SequentialLet"
      "SetLiteralUpdate"
      "UnfortunateArgName"
      "UnneededRec"
      "UnusedArg"
      "UnusedLetBind"
      "UpdateEmptySet"
      "BetaReduction"
      "EmptyVariadicParamSet"
      "UnneededAntiquote"
      "no-FreeLetInFunc"
      "no-AlphabeticalArgs"
      "no-AlphabeticalBindings"
    ];
  };
}
