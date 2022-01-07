local utils = require("cloud.utils")
local map = utils.map

local cmd = vim.cmd
local g = vim.g
local opt = vim.opt
local wo = vim.wo

-- lines of history for vim to remember
opt.history = 500

-- change to directory of file
opt.autochdir = true

-- filetype plugins
cmd("filetype plugin on")
cmd("filetype indent on")

-- auto load when a file is changed
opt.autoread = true
cmd("autocmd FocusGained,BufEnter * checktime")

g.loaded_node_provider = 1
g.loaded_python_provider = 1
g.loaded_perl_provider = 0
g.loaded_ruby_provider = 0

-- ui things
wo.signcolumn = "yes"

-- incremental live completion
opt.inccommand = "nosplit"

-- line numbers
opt.number = true

-- show line at cursor
opt.cursorline = true

-- 7 lines to cursor when moving vertically
opt.so = 7

-- wild menu
opt.wildmenu = true

-- ignore a variety of irrelevant files
opt.wildignore =
  "*/tmp/*,*.so,*.a,*.dylib,*.swp,*.zip,*.gz,*.bz2,*.xz,*.7z,*/__pycache__,__pycache__/*,*.pyc,*.pyo"

-- show the current position
opt.ruler = true

-- height of the command bar
opt.cmdheight = 1

-- close hide buffers when abandoned
opt.hidden = true

-- ignore case when searching ...
opt.ignorecase = true
opt.wildignorecase = true

-- .. but also try to be smart about it
opt.smartcase = true

-- highlight search results
opt.hlsearch = true

-- browser-like searching
opt.incsearch = true

-- magic...?
opt.magic = true

-- show matching brackets when rolling over
opt.showmatch = true

-- how many tenths of a second to blink when matching brackets
opt.mat = 2

-- no annoying sound on errors
opt.errorbells = false
opt.visualbell = false
opt.tm = 500

-- extra margin on left
opt.foldcolumn = "1"

-- syntax things
cmd("syntax enable")
cmd("syntax on")

-- utf8 as the the default encoding
opt.encoding = "utf8"

-- unix as standard file type
opt.ffs = "unix,dos,mac"

-- stuff I don't need
opt.updatetime = 250
opt.backup = false
opt.writebackup = false
opt.swapfile = false
opt.undofile = true
cmd("set undodir=$HOME/.cache/nvim")

-- spaces, tabs, religious wars, etc
opt.expandtab = true
opt.smarttab = true

-- tab == 4 spaces
opt.shiftwidth = 4
opt.softtabstop = 4

-- line break on 80 chars
opt.lbr = true
opt.tw = 80

-- auto indent + smart indent
opt.ai = true
opt.si = true

-- set clipboard to system clipboard
opt.clipboard = "unnamedplus"

-- redraw lazily
opt.lazyredraw = true

-- don't show mode
opt.showmode = false

-- no startofline
opt.startofline = false

-- diff opt
opt.diffopt = "filler,iwhite"

-- do not wrap lines
opt.wrap = false

-- textwidth = 0
opt.textwidth = 0

-- high searches when in normal mode and underscore is pressed
map("", "_", ":noh<CR>", { silent = true })

-- window nav
map("n", "<C-k>", "<C-w><Up>")
map("n", "<C-j>", "<C-w><Down>")
map("n", "<C-l>", "<C-w><Right>")
map("n", "<C-h>", "<C-w><Left>")

-- command mode nav
map("c", "<C-a>", "<Home>")
map("c", "<C-e>", "<End>")
map("c", "<C-p>", "<Up>")
map("", "<C-n>", "<Down>")
map("c", "<C-b>", "<Left>")
map("c", "<C-f>", "<Right>")

map("n", "<C-n>", ":NvimTreeToggle<CR>")
map("n", "<leader>r", ":NvimTreeRefresh<CR>")
map("n", "<leader>f", ":NvimTreeFindFile<CR>")

-- replace easily
map("n", "<leader>s", [[:%s/\<<C-r><C-w>\>/]])

-- pin shifting
map("v", "<", "<gv")
map("v", ">", ">gv")
-- map("v", "//", "y/<C-R>\"<CR>")

-- tab movement
map("", "<leader>tn", ":tabnew<CR>")

-- various filetype settings
cmd("autocmd BufRead,BufNewFile *.ll setlocal filetype=llvm")
cmd("autocmd BufRead,BufNewFile *.pxi,*.pyx,*.pxd setlocal filetype=cython")
cmd("autocmd BufRead,BufNewFile berglas-*,*.toml.tpl setlocal filetype=toml")
cmd(
  "autocmd BufRead,BufNewFile .condarc,*condarc,*.yaml.tpl,*.yml.tpl,*.yml.j2,*.yaml.j2 setlocal filetype=yaml"
)
cmd("autocmd BufRead,BufNewFile *.rkt setlocal filetype=racket")
cmd("autocmd BufRead,BufNewFile *.avsc,*.json.tpl,*.ipynb setlocal filetype=json")
cmd("autocmd BufRead,BufNewFile *.jsx setlocal filetype=javascript.jsx")

map("n", "<F4>", " :lua require'dapui'.toggle()<CR>", { silent = true })
map("n", "<F5>", " :lua require'dap'.continue()<CR>", { silent = true })
map("n", "<F10>", ":lua require'dap'.step_over()<CR>", { silent = true })
map("n", "<F11>", ":lua require'dap'.step_into()<CR>", { silent = true })
map("n", "<F12>", ":lua require'dap'.step_out()<CR>", { silent = true })
map("n", "<leader>b", ":lua require'dap'.toggle_breakpoint()<CR>", { silent = true })
map(
  "n",
  "<leader>B",
  ":lua require'dap'.set_breakpoint(vim.fn.input('Breakpoint condition: '))<CR>",
  { silent = true }
)
map(
  "n",
  "<leader>lp",
  ":lua require'dap'.set_breakpoint(nil, nil, vim.fn.input('Log point message: '))<CR>",
  { silent = true }
)
map("n", "<leader>dr", ":lua require'dap'.repl.open()<CR>", { silent = true })
map("n", "<leader>dl", ":lua require'dap'.run_last()<CR>", { silent = true })

-- tab/spaces for specific file types
cmd(
  "autocmd FileType html,sh,fbs,groovy,yaml,crystal,ruby,racket,markdown,json,hcl,typescript,javascript.jsx,c,cpp,javascript setlocal shiftwidth=2 tabstop=2"
)
cmd("autocmd FileType go setlocal shiftwidth=4 tabstop=4")

-- i don't remember what this does
cmd("autocmd BufEnter * silent! lcd %:p:h")

opt.switchbuf = "useopen,usetab,newtab"
opt.stal = 2

-- show full path to the current file
map("n", "<leader>ff", [[:echo expand("%:p:")<cr>]])

-- last edit position when opening a file
cmd(
  [[au BufReadPost * if line("'\"") > 1 && line("'\"") <= line("$") | exe "normal! g'\"" | endif]]
)

-- show last status line
opt.laststatus = 2

-- Pressing toggle spell checking
map("", "<leader>ss", ":setlocal spell!<cr>")

-- Remove the Windows ^M - when the encodings gets messed up
map("", "<leader>m", "mmHmt:%s/<C-V><cr>//ge<cr>'tzt'm")

-- Toggle paste mode on and off
map("", "<leader>pp", ":setlocal paste!<cr>")
cmd("let @p='Obreakpoint()'")
