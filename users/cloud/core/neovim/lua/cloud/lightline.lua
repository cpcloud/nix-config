vim.g.lightline = {
    colorscheme = "gruvbox",
    enable = {tabline = 0},
    active = {
        left = {
            {"mode", "paste"}, {"gitbranch", "readonly", "filename", "modified"}
        },
        right = {
            {"lineinfo"}, {"percent"},
            {"fileformat", "fileencoding", "filetype"}
        }
    }
}
