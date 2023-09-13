local ok, telescope = pcall(require, "telescope")

if not ok then
	return
end

telescope.setup({
	defaults = {
		preview = {
			treesitter = false,
		},
		vimgrep_arguments = {
			"rg",
			"--color=never",
			"--no-heading",
			"--with-filename",
			"--line-number",
			"--column",
			"--smart-case",
			"--hidden",
			"--no-require-git",
			"--follow",
			"--glob",
			"!.git/*",
			"--glob",
			"!node_modules/*",
			"--glob",
			"!*.svg",
		},
		mappings = {
			i = {
				["<C-u>"] = false, -- clear prompt
			},
		},
	},
	extensions = {},
})

local my_utils = require("utils")

-- Falling back to find_files if git_files can't find a .git directory
local function telescope_project_files()
	if require("utils").is_git_repo() then
		require("telescope.builtin").git_files({ show_untracked = true })
	else
		require("telescope.builtin").find_files()
	end
end

local function telescope_live_grep()
	local opts = {}

	if my_utils.is_git_repo() then
		opts = {
			cwd = my_utils.get_git_root(),
		}
	end

	local available = pcall(require("telescope.builtin").live_grep, opts)
	if not available then
		return
	end
end

-- nnoremap("<leader><space>", require("telescope.builtin").buffers)
-- nnoremap("<leader>sf", telescope_project_files)
-- nnoremap("<leader>sg", telescope_live_grep)
-- nnoremap("<leader>sd", require("telescope.builtin").diagnostics)
-- nnoremap("<leader>sb", require("telescope.builtin").current_buffer_fuzzy_find)
-- nnoremap("<leader>?", require("telescope.builtin").oldfiles)
-- nnoremap("<leader>/", function()
-- 	-- You can pass additional configuration to telescope to change theme, layout, etc.
-- 	require("telescope.builtin").current_buffer_fuzzy_find(require("telescope.themes").get_dropdown({
-- 		winblend = 10,
-- 		previewer = false,
-- 	}))
-- end)
