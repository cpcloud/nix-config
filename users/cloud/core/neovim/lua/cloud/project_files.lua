local telescope = require("telescope.builtin")

return {
    project_files = function()
        xpcall(telescope.git_files, function(_) telescope.find_files() end)
    end
}
