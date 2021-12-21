local telescope = require("telescope")

telescope.setup(
  {
    defaults = {
      file_ignore_patterns = {
        "node_modules",
        ".git"
      }
    },
    extensions = {
      fzf = {
        fuzzy = false, -- false will only do exact matching
        override_generic_sorter = true, -- override the generic sorter
        override_file_sorter = true, -- override the file sorter
        case_mode = "smart_case" -- or "ignore_case" or "respect_case"
      }
    }
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
      find_command = {"fd", "--hidden","--exclude", ".git"}
    }
  )
end
telescope.load_extension("fzf")

return M
