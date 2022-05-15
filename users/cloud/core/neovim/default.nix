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

  vim-xonsh = pkgs.vimUtils.buildVimPlugin {
    name = "vim-xonsh";
    src = pkgs.fetchFromGitHub {
      owner = "meatballs";
      repo = "vim-xonsh";
      rev = "2028aacfae3f5b54f8b07fb21fa729afdfac8050";
      sha256 = "sha256-0+dqtlz8LeyOoSiS12rv8aLdzOMj31PuYAyDYWnpNzw=";
    };
  };

  extraPython3Packages = p: with p; [
    black
    isort
    flake8
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
          gnumake
          go
          gopls
          jq
          nix-linter
          pyright
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
        neovim-ayu
        indent-blankline-nvim-lua
        lsp-colors-nvim
        lsp_signature-nvim
        bufferline-nvim

        # various dev tools
        nvim-gps # gps
        feline-nvim # line thing
        nvim-autopairs # auto paren/brackets/etc
        nvim-bufdel # better buffer deletion
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
        (nvim-treesitter.withPlugins
          (_: pkgs.tree-sitter.allGrammars))
        nvim-treesitter-textobjects

        # indicate current context (e.g., function, class, etc)
        nvim-treesitter-context

        # a bunch of other syntax for langs that tree-sitter doesn't
        # implement yet
        vim-polyglot

        # debugging
        nvim-dap
        nvim-dap-ui

        # xonsh highlighting
        vim-xonsh
      ];

      extraConfig = "lua require('init')";
    };
  };

  xdg.configFile."nvim/lua".source = ./lua;
}
