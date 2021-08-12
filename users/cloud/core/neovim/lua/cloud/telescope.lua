local utils = require("cloud.utils")
local map = utils.map

require("telescope").setup({
  defaults = {
    mappings = { i = { ["<C-u>"] = false, ["<C-d>"] = false } },
    generic_sorter = require("telescope.sorters").get_fzy_sorter,
    file_sorter = require("telescope.sorters").get_fzy_sorter,
  },
})
-- Add leader shortcuts
map(
  "n",
  "<C-p>",
  [[<cmd>lua require("cloud.project_files").project_files()<cr>]],
  { silent = true }
)
map("n", "<C-b>", [[<cmd>lua require("telescope.builtin").buffers()<cr>]], { silent = true })
map(
  "n",
  "<leader>l",
  [[<cmd>lua require("telescope.builtin").current_buffer_fuzzy_find()<cr>]],
  { silent = true }
)
map("n", "<leader>t", [[<cmd>lua require("telescope.builtin").tags()<cr>]], { silent = true })
map("n", "<leader>?", [[<cmd>lua require("telescope.builtin").oldfiles()<cr>]], { silent = true })
map(
  "n",
  "<leader>w",
  [[<cmd>lua require("telescope.builtin").grep_string()<cr>]],
  { silent = true }
)
map("n", "<leader>fg", [[<cmd>lua require("cloud.live_grep").live_grep()<cr>]], { silent = true })
map(
  "n",
  "<leader>o",
  [[<cmd>lua require("telescope.builtin").tags{ only_current_buffer = true }<cr>]],
  { silent = true }
)
map(
  "n",
  "<leader>gc",
  [[<cmd>lua require("telescope.builtin").git_commits()<cr>]],
  { silent = true }
)
map(
  "n",
  "<leader>gb",
  [[<cmd>lua require("telescope.builtin").git_branches()<cr>]],
  { silent = true }
)
map(
  "n",
  "<leader>gs",
  [[<cmd>lua require("telescope.builtin").git_status()<cr>]],
  { silent = true }
)
map(
  "n",
  "<leader>gp",
  [[<cmd>lua require("telescope.builtin").git_bcommits()<cr>]],
  { silent = true }
)
