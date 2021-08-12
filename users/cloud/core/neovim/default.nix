{ pkgs, lib, ... }:
let
  inherit (lib.strings) escapeNixString;

  # override the python-lsp-server package to remove a bunch of packages that i
  # don't like to use for formatting/linting
  # black e.g., won't work if autopep8 or yapf are in the buildInputs of python-lsp-server
  pkgsToRemove = pkgs: with pkgs; [ autopep8 yapf ];
  python3 =
    let
      packageOverrides = self: super: {
        python-lsp-server = super.python-lsp-server.overridePythonAttrs (attrs:
          {
            propagatedBuildInputs = builtins.filter
              (pkg: !(builtins.elem pkg (pkgsToRemove self)))
              (attrs.propagatedBuildInputs or [ ]);
            checkInputs = (attrs.checkInputs or [ ]) ++ (pkgsToRemove self);
          });
      };
    in
    pkgs.python3.override {
      inherit packageOverrides;
      self = python3;
    };
  styluaSettings = builtins.fromTOML (
    lib.replaceStrings [ "_" ] [ "-" ] (lib.readFile ../../../../stylua.toml)
  );
  styluaSettingsArgs = lib.concatStringsSep
    " "
    (lib.mapAttrsToList (name: value: "--${name}=${toString value}") styluaSettings);
  styluaWithFormat = pkgs.writeSaneShellScriptBin {
    name = "stylua";
    src = ''${pkgs.stylua}/bin/stylua ${styluaSettingsArgs} "$@"'';
  };
in
{
  home = {
    packages = [ pkgs.neovim-remote ];
    sessionVariables = {
      EDITOR = "nvim";
      VISUAL = "nvim";
    };
  };

  programs = {
    git.extraConfig = {
      core.editor = "nvr --remote-wait-silent";

      diff.tool = "nvr";
      "difftool \"nvr\"" = {
        cmd = "nvr -s -d $LOCAL $REMOTE";
      };

      merge.tool = "nvr";
      "mergetool \"nvr\"" = {
        cmd = "nvr -s -d $LOCAL $BASE $REMOTE $MERGED -c 'wincmd J | wincmd ='";
      };
    };

    neovim =
      {
        enable = true;

        vimAlias = true;
        vimdiffAlias = true;

        withRuby = false;
        withNodeJs = true;
        withPython3 = true;

        extraPython3Packages = (p: with p; [
          pyls-flake8
          pyls-isort
          pylsp-mypy
          python-lsp-black
          python-lsp-server
          debugpy
        ]);

        extraPackages = (
          with pkgs; [
            bat
            clang-tools
            ctags
            fd
            gcc
            go
            gopls
            jq
            nix-linter
            ripgrep
            styluaWithFormat
            sumneko-lua-language-server
            texlab
            tree-sitter
            yaml-language-server
          ]
        ) ++ [
          (python3.withPackages (
            p: with p; [
              pyls-flake8
              pyls-isort
              pylsp-mypy
              python-lsp-black
              python-lsp-server
              debugpy
            ]
          ))
        ] ++ (
          with pkgs.nodePackages; [
            eslint
            diagnostic-languageserver
          ]
        ) ++ [
          (pkgs.writeSaneShellScriptBin {
            name = "prettier";
            src = ''
              ${pkgs.nodePackages.prettier}/bin/prettier \
              --plugin-search-dir "${pkgs.nodePackages.prettier-plugin-toml}/lib" \
              "$@"
            '';
          })
        ];

        plugins = with pkgs.vimPlugins; [
          # ui/ux
          indent-blankline-nvim-lua
          lightline-vim
          lightline-gruvbox-vim
          lsp-colors-nvim
          lsp_signature-nvim
          nvim-bufferline-lua
          nvim-base16 # base16-gruvbox-dark-hard
          gruvbox # for lightline

          # various dev tools
          auto-pairs # auto paren/brackets/etc
          nerdcommenter # commenting
          nerdtree # better directory exploration
          nvim-lightbulb # code action indicator
          nvim-web-devicons # icons for various things in neovim
          telescope-nvim # sweet sweet telescoping
          trouble-nvim # a better quickfix/loclist for LSPs
          vim-better-whitespace # manage whitespace
          vim-crates # show crates in Cargo.toml that can be updated
          vim-fugitive # git stuff
          vim-gitgutter # changes in the vim gutter
          vim-sleuth # figure out whitespace
          vim-surround # awesome paren/bracket generation/changing
          vim-unimpaired
          snippets-nvim
          rust-tools-nvim # type inference indicators for rust

          # lang/app/framework specific packages
          vimtex # tex IDE

          # completion
          nvim-compe
          nvim-lspconfig

          # syntax
          nvim-treesitter
          nvim-treesitter-context
          vim-polyglot

          # debugging
          nvim-dap
          nvim-dap-ui
        ];

        extraConfig = "lua require('init')";
      };
  };

  xdg.configFile."nvim/lua".source = ./lua;
}
