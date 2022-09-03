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

-- Falling back to find_files if git_files can't find a .git directory
local function project_files()
	local available = pcall(require("telescope.builtin").git_files, { show_untracked = true })
	if not available then
		require("telescope.builtin").find_files({ hidden = true })
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

local function keymap()
	local opts = {}
	local available = pcall(require("telescope.builtin").keymaps, opts)
	if not available then
		return
	end
end

-- mappings
local nnoremap = require("utils").nnoremap
nnoremap("<leader>fi", project_files)
nnoremap("<leader>fg", live_grep)
nnoremap("<leader>kk", keymap)
nnoremap("<leader>tr", require("telescope.builtin").lsp_references)
nnoremap("<leader>td", require("telescope.builtin").diagnostics)
