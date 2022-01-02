local telescope = require("telescope")

telescope.setup(
  {
    defaults = {
      file_ignore_patterns = {
        "node_modules"
      }
    },
  }
)

local M = {}

function M.my_git_files()
  require("telescope.builtin").git_files(
    {
      hidden = true,
      show_untracked = true
    }
  )
end

function M.my_find_files()
  require("telescope.builtin").find_files(
    {
      find_command = {"fd", "-H", "-E", ".git"}
    }
  )
end
return M
