local nvim_lsp = require("lspconfig")

-- bindings
local on_attach = function(_, bufnr)
  vim.api.nvim_buf_set_option(bufnr, "omnifunc", "v:lua.vim.lsp.omnifunc")

  local map = vim.api.nvim_buf_set_keymap
  local opts = { noremap = true, silent = true }
  map(bufnr, "n", "gD", "<Cmd>lua vim.lsp.buf.declaration()<CR>", opts)
  map(bufnr, "n", "gd", "<Cmd>lua vim.lsp.buf.definition()<CR>", opts)
  map(bufnr, "n", "K", "<Cmd>lua vim.lsp.buf.hover()<CR>", opts)
  map(bufnr, "n", "gi", "<cmd>lua vim.lsp.buf.implementation()<CR>", opts)
  map(bufnr, "n", "<C-k>", "<cmd>lua vim.lsp.buf.signature_help()<CR>", opts)
  map(bufnr, "n", "<leader>wa", "<cmd>lua vim.lsp.buf.add_workspace_folder()<CR>", opts)
  map(bufnr, "n", "<leader>wr", "<cmd>lua vim.lsp.buf.remove_workspace_folder()<CR>", opts)
  map(
    bufnr,
    "n",
    "<leader>wl",
    "<cmd>lua print(vim.inspect(vim.lsp.buf.list_workspace_folders()))<CR>",
    opts
  )
  map(bufnr, "n", "<leader>D", "<cmd>lua vim.lsp.buf.type_definition()<CR>", opts)
  map(bufnr, "n", "<leader>rn", "<cmd>lua vim.lsp.buf.rename()<CR>", opts)
  map(bufnr, "n", "gr", "<cmd>lua vim.lsp.buf.references()<CR>", opts)
  map(bufnr, "n", "<leader>ca", "<cmd>lua vim.lsp.buf.code_action()<CR>", opts)
  map(bufnr, "n", "<leader>e", "<cmd>lua vim.lsp.diagnostic.show_line_diagnostics()<CR>", opts)
  map(bufnr, "n", "<leader>p", "<cmd>lua vim.lsp.diagnostic.goto_prev()<CR>", opts)
  map(bufnr, "n", "<leader>n", "<cmd>lua vim.lsp.diagnostic.goto_next()<CR>", opts)
  map(bufnr, "n", "<leader>q", "<cmd>lua vim.lsp.diagnostic.set_loclist()<CR>", opts)

  map(bufnr, "n", "<leader>B", "<cmd>lua require'dap'.toggle_breakpoint()<CR>", opts)
  map(bufnr, "n", "<leader>C", "<cmd>lua require'dap'.continue()<CR>", opts)
  map(bufnr, "n", "<leader>S", "<cmd>lua require'dap'.step_into()<CR>", opts)
  map(bufnr, "n", "<leader>N", "<cmd>lua require'dap'.step_over()<CR>", opts)
  map(bufnr, "n", "<leader>O", "<cmd>lua require'dap'.step_out()<CR>", opts)
  map(
    bufnr,
    "n",
    "<leader>bc",
    [[lua require'dap'.set_breakpoint(vim.fn.input('Breakpoint condition: '))<CR>]],
    opts
  )
  map(
    bufnr,
    "n",
    "<leader>lp",
    [[lua require'dap'.set_breakpoint(nil, nil, vim.fn.input('Log point message: '))<CR>]],
    opts
  )

  require("lsp_signature").on_attach()
end

local prettier_root_patterns = {
  ".prettierrc",
  ".prettierrc.json",
  ".prettierrc.toml",
  ".prettierrc.json",
  ".prettierrc.yml",
  ".prettierrc.yaml",
  ".prettierrc.json5",
  ".prettierrc.js",
  ".prettierrc.cjs",
  "prettier.config.js",
  "prettier.config.cjs",
  ".git",
}

-- Enable the following language servers
local servers = {
  "clangd",
  "pyright",
  "texlab",
  "gopls",
  "yamlls",
  "diagnosticls",
  "sumneko_lua",
}

local runtime_path = vim.split(package.path, ";")
table.insert(runtime_path, "lua/?.lua")
table.insert(runtime_path, "lua/?/init.lua")

local lsps_settings = {
  sumneko_lua = {
    cmd = { "lua-language-server" },
    settings = {
      Lua = {
        runtime = { version = "LuaJIT", path = runtime_path },
        diagnostics = { globals = { "vim" } },
        workspace = { library = vim.api.nvim_get_runtime_file("", true) },
        telemetry = { enable = false },
      },
    },
  },
  pyright = {
    settings = {
      python = {
        analysis = {
          autoSearchPaths = true,
          diagnosticMode = "openFilesOnly",
          typeCheckingMode = "off",
          useLibraryCodeForTypes = true,
        },
      },
    },
  },
  diagnosticls = {
    filetypes = {
      "json",
      "lua",
      "nix",
      "python",
      "sh",
      "toml",
      "typescript",
      "yaml",
    },
    init_options = {
      filetypes = {
        sh = "shellcheck",
        nix = "nix-linter",
        typescript = "eslint",
        python = "flake8",
      },
      linters = {
        flake8 = {
          sourceName = "flake8",
          command = "flake8",
          args = { [[--format=%(row)d,%(col)d,%(code).1s,%(code)s: %(text)s]], "-" },
          debounce = 100,
          offsetLine = 0,
          offsetColumn = 0,
          formatLines = 1,
          formatPattern = {
            [[(\d+),(\d+),([A-Z]),(.*)(\r|\n)*$]],
            { line = 1, column = 2, security = 3, message = { "[flake8] ", 4 } },
          },
          securities = {
            W = "warning",
            E = "error",
            F = "error",
            C = "error",
            N = "error",
          },
        },
        shellcheck = {
          sourceName = "shellcheck",
          command = "shellcheck",
          debounce = 100,
          args = { "--format", "json1", "-" },
          parseJson = {
            errorsRoot = "comments",
            sourceName = "file",
            line = "line",
            column = "column",
            endLine = "endLine",
            endColumn = "endColumn",
            security = "level",
            message = "[shellcheck] ${message} [SC${code}]",
          },
          securities = {
            error = "error",
            warning = "warning",
            info = "info",
            style = "hint",
          },
        },
        ["nix-linter"] = {
          command = "nix-linter",
          sourceName = "nix-linter",
          debounce = 100,
          parseJson = {
            line = "pos.spanBegin.sourceLine",
            column = "pos.spanBegin.sourceColumn",
            endLine = "pos.spanEnd.sourceLine",
            endColumn = "pos.spanEnd.sourceColumn",
            message = "${description}",
          },
          securities = { undefined = "warning" },
        },
        eslint = {
          sourceName = "eslint",
          command = "eslint",
          debounce = 100,
          args = { "--stdin", "--stdin-filename", "%filepath", "--format", "json" },
          parseJson = {
            errorsRoot = "[0].messages",
            line = "line",
            column = "column",
            endLine = "endLine",
            endColumn = "endColumn",
            message = "[eslint] ${message} [${ruleId}]",
            security = "severity",
          },
          securities = { ["1"] = "warning", ["2"] = "error" },
          rootPatterns = {
            ".eslintrc",
            ".eslintrc.cjs",
            ".eslintrc.js",
            ".eslintrc.json",
            ".eslintrc.yaml",
            ".eslintrc.yml",
          },
        },
      },
      formatters = {
        black = {
          command = "black",
          args = { "--quiet", "-" },
          rootPatterns = { ".git", "pyproject.toml", "setup.py" },
        },
        isort = {
          command = "isort",
          args = { "--quiet", "--stdout", "-" },
          rootPatterns = { ".isort.cfg", "pyproject.toml", ".git" },
        },
        prettier = {
          command = "prettier",
          args = { "--stdin", "--stdin-filepath", "%filepath" },
          rootPatterns = prettier_root_patterns,
        },
        stylua = { command = "stylua", args = { "-", "--stdin-filepath", "%filepath" } },
        ["nixpkgs-fmt"] = { command = "nixpkgs-fmt" },
        shfmt = {
          command = "shfmt",
          args = { "-i", "2", "-s", "-sr", "-filename", "%filepath" },
        },
      },
      formatFiletypes = {
        lua = "stylua",
        nix = "nixpkgs-fmt",
        sh = "shfmt",
        toml = "prettier",
        yaml = "prettier",
        typescript = "prettier",
        json = "prettier",
        python = { "black", "isort" },
      },
    },
  },
}

local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities.textDocument.completion.completionItem.snippetSupport = true
capabilities.textDocument.completion.completionItem.resolveSupport = {
  properties = { "documentation", "detail", "additionalTextEdits" },
}

for _, lsp in ipairs(servers) do
  nvim_lsp[lsp].setup(vim.tbl_extend("force", {
    on_attach = on_attach,
    capabilities = capabilities,
  }, lsps_settings[lsp] or {}))
end

-- Map :Format to vim.lsp.buf.formatting()
vim.cmd([[ command! Format execute "lua vim.lsp.buf.formatting()" ]])

vim.cmd([[autocmd CursorHold,CursorHoldI * lua require'nvim-lightbulb'.update_lightbulb()]])

vim.cmd([[au FileType dap-repl lua require('dap.ext.autocompl').attach()]])

return { on_attach = on_attach, capabilities = capabilities }
