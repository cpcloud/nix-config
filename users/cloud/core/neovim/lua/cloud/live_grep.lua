local telescope = require("telescope.builtin")

local trim = function(s) return s:match("^%s*(.-)%s*$") end

return {
    live_grep = function()
        xpcall(function()
            local handle = io.popen("git root")
            local result = handle:read("*a")
            handle:close()
            telescope.live_grep({search_dirs = {trim(result)}})
        end, function(_) telescope.live_grep() end)
    end
}
