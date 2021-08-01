local mappings = {
    r = ":Reword<CR><DOWN>",
    f = ":Fixup<CR><DOWN>",
    s = ":Squash<CR><DOWN>",
    e = ":Edit<CR><DOWN>",
    p = ":Pick<CR><DOWN>",
    D = ":Drop<CR>",
    ["<C-j>"] = ":move +1<CR>",
    ["<C-k>"] = ":move -2<CR>",
}

for k, v in pairs(mappings) do
    vim.cmd(string.format("autocmd FileType gitrebase nnoremap <silent> %s %s", k, v))
end
