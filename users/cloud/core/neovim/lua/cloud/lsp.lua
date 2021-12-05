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

local prettier_config_files = {
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
  "pylsp",
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
  diagnosticls = {
    filetypes = { "sh", "nix", "lua", "json", "proto", "toml", "typescript", "yaml" },
    init_options = {
      filetypes = {
        sh = "shellcheck",
        nix = "nix-linter",
        typescript = "eslint",
        proto = "buf-lint",
      },
      linters = {
        ["buf-lint"] = {
          command = "buf",
          debounce = 100,
          args = { "lint", "--error-format", "json" },
          sourceName = "buf-lint",
          parseJson = {
            sourceName = "path",
            line = "start_line",
            column = "start_column",
            endLine = "end_line",
            endColumn = "end_column",
            message = "${message} [${type}]",
          },
          securities = { undefined = "warning" },
        },
        shellcheck = {
          command = "shellcheck",
          debounce = 100,
          args = { "--format", "json", "-" },
          sourceName = "shellcheck",
          parseJson = {
            line = "line",
            column = "column",
            endLine = "endLine",
            endColumn = "endColumn",
            message = "${message} [${code}]",
            security = "level",
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
          command = "eslint",
          rootPatterns = { ".git" },
          debounce = 100,
          args = {
            "--stdin",
            "--stdin-filename",
            "%filepath",
            "--format",
            "json",
          },
          sourceName = "eslint",
          parseJson = {
            errorsRoot = "[0].messages",
            line = "line",
            column = "column",
            endLine = "endLine",
            endColumn = "endColumn",
            message = "${message} [${ruleId}]",
            security = "severity",
          },
          securities = { ["2"] = "error", ["1"] = "warning" },
        },
      },
      formatters = {
        stylua = { command = "stylua", args = { "-", "--stdin-filepath", "%filepath" } },
        ["nixpkgs-fmt"] = { command = "nixpkgs-fmt" },
        shfmt = {
          command = "shfmt",
          args = { "-i", "2", "-s", "-sr", "-filename", "%filepath" },
        },
        prettier = {
          command = "prettier",
          args = { "--stdin", "--stdin-filepath", "%filepath" },
          rootPatterns = prettier_config_files,
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
