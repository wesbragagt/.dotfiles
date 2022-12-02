local ok, telescope = pcall(require, "telescope")

if not ok then
	return
end

telescope.setup({
	defaults = {
		mappings = {
			i = {
				["<esc>"] = require("telescope.actions").close, -- close on escape
				["<C-u>"] = false, -- clear prompt
			},
		},
	},
	extensions = {},
})

telescope.load_extension("fzf")

-- Falling back to find_files if git_files can't find a .git directory
local function project_files()
	local is_in_git_repo = require("telescope.utils").get_os_command_output({
		"git",
		"rev-parse",
		"--is-inside-work-tree",
	})

	if is_in_git_repo then
		require("telescope.builtin").git_files({ show_untracked = true })
	else
		require("telescope.builtin").find_files()
	end
end

local function live_grep()
	local opts = {
		cwd = vim.lsp.get_active_clients()[1].config.root_dir,
	}
	local available = pcall(require("telescope.builtin").live_grep, opts)
	if not available then
		return
	end
end

-- mappings
local nnoremap = require("utils").nnoremap
nnoremap("<leader><space>", require("telescope.builtin").buffers)
nnoremap("<leader>sf", project_files)
nnoremap("<leader>sg", live_grep)
nnoremap("<leader>sd", require("telescope.builtin").diagnostics)
nnoremap("<leader>sb", require("telescope.builtin").current_buffer_fuzzy_find)
nnoremap("<leader>?", require("telescope.builtin").oldfiles)
