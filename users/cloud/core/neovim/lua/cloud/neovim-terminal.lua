vim.cmd "augroup neovim_terminal"
vim.cmd "autocmd!"
vim.cmd "autocmd TermOpen * startinsert"
vim.cmd "autocmd TermOpen * setlocal nonumber norelativenumber"
vim.cmd "augroup END"
