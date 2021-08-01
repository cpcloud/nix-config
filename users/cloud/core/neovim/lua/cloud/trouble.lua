local utils = require("cloud.utils")
local map = utils.map

require("trouble").setup {}

map("n", "<leader>T", "<cmd>TroubleToggle<cr>", {silent = true})
map("n", "<leader>Tw", "<cmd>Trouble lsp_workspace_diagnostics<cr>",
    {silent = true})
map("n", "<leader>Td", "<cmd>Trouble lsp_document_diagnostics<cr>",
    {silent = true})
map("n", "<leader>Tl", "<cmd>Trouble loclist<cr>", {silent = true})
map("n", "<leader>Tq", "<cmd>Trouble quickfix<cr>", {silent = true})
