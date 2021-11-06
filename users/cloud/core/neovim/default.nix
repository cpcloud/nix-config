{ pkgs, lib, ... }:
let
  inherit (lib.strings) escapeNixString;

  # override the python-lsp-server package to remove a bunch of packages that i
  # don't like to use for formatting/linting
  # black e.g., won't work if autopep8 or yapf are in the buildInputs of python-lsp-server
  python3 =
    let
      pkgsToRemove = pkgs: with pkgs; [ autopep8 yapf ];
      packageOverrides = pyself: pysuper: {
        python-lsp-server = pysuper.python-lsp-server.overridePythonAttrs (attrs:
          {
            propagatedBuildInputs = builtins.filter
              (pkg: !(builtins.elem pkg (pkgsToRemove pyself)))
              (attrs.propagatedBuildInputs or [ ]);
            checkInputs = (attrs.checkInputs or [ ]) ++ (pkgsToRemove pyself);
          });
      };
    in
    pkgs.python3.override {
      inherit packageOverrides;
      self = python3;
    };

  extraPython3Packages = p: with p; [
    pyls-flake8
    pyls-isort
    pylsp-mypy
    python-lsp-black
    python-lsp-server
  ] ++ lib.optional (!pkgs.stdenv.isAarch64) debugpy;
in
{
  home = {
    packages = [ pkgs.neovim-remote ];
    sessionVariables = rec {
      EDITOR = "nvim";
      VISUAL = EDITOR;
    };
  };

  programs = {
    neovim = {
      enable = true;

      vimAlias = true;
      vimdiffAlias = true;

      withRuby = false;
      withNodeJs = true;
      withPython3 = true;

      inherit extraPython3Packages;

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
          sumneko-lua-language-server
          texlab
          tree-sitter
          yaml-language-server
          prettierWithToml
          styluaWithFormat
        ]
      ) ++ [
        (python3.withPackages extraPython3Packages)
      ] ++ (
        with pkgs.nodePackages; [
          eslint
          diagnostic-languageserver
        ]
      ) ++ lib.optional (!pkgs.stdenv.isAarch64) pkgs.shellcheck;

      plugins = with pkgs.vimPlugins; [
        # ui/ux
        indent-blankline-nvim-lua
        lightline-vim
        lightline-gruvbox-vim
        lsp-colors-nvim
        lsp_signature-nvim
        bufferline-nvim
        nvim-base16 # base16-gruvbox-dark-hard
        gruvbox # for lightline

        # various dev tools
        auto-pairs # auto paren/brackets/etc
        nerdcommenter # commenting
        nvim-tree-lua # better directory exploration
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

        # indicate current context (e.g., function, class, etc)
        nvim-treesitter-context

        # a bunch of other syntax for langs that tree-sitter doesn't
        # implement yet
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
