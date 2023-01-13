local ok, telescope = pcall(require, "telescope")

if not ok then
	return
end

telescope.load_extension("fzf")

telescope.setup({
	defaults = {
		vimgrep_arguments = {
			"rg",
			"--no-heading",
			"--with-filename",
			"--line-number",
			"--column",
			"--smart-case",
		},
		mappings = {
			i = {
				["<C-u>"] = false, -- clear prompt
			},
		},
	},
	extensions = {},
})

-- Falling back to find_files if git_files can't find a .git directory
local function project_files()
	local _, ret, _ = require("telescope.utils").get_os_command_output({ "git", "rev-parse", "--is-inside-work-tree" })
	print(ret)
	if ret == 0 then
		require("telescope.builtin").git_files(require("telescope.themes").get_dropdown({
			previewer = false,
			show_untracked = true,
		}))
	else
		require("telescope.builtin").find_files(require("telescope.themes").get_dropdown({
			previewer = false,
			show_untracked = true,
		}))
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
nnoremap("<leader>/", function()
	-- You can pass additional configuration to telescope to change theme, layout, etc.
	require("telescope.builtin").current_buffer_fuzzy_find(require("telescope.themes").get_dropdown({
		winblend = 10,
		previewer = false,
	}))
end)
