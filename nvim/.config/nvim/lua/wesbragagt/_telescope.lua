local present, telescope = pcall(require, "telescope")

if not present then
	return
end
ACTIONS = require("telescope.actions")
-- check for any override
telescope.setup({
	defaults = {
		vimgrep_arguments = {
			"rg",
			"--color=never",
			"--no-heading",
			"--with-filename",
			"--line-number",
			"--column",
			"--smart-case",
		},
		prompt_prefix = "   ",
		selection_caret = "  ",
		entry_prefix = "  ",
		initial_mode = "insert",
		selection_strategy = "reset",
		sorting_strategy = "ascending",
		layout_strategy = "horizontal",
		layout_config = {
			horizontal = {
				prompt_position = "top",
				preview_width = 0.55,
				results_width = 0.8,
			},
			width = 0.87,
			height = 0.80,
			preview_cutoff = 120,
		},
		file_sorter = require("telescope.sorters").get_fuzzy_file,
		file_ignore_patterns = { "node_modules", ".git" },
		generic_sorter = require("telescope.sorters").get_generic_fuzzy_sorter,
		path_display = { "truncate" },
		winblend = 0,
		border = {},
		borderchars = { "─", "│", "─", "│", "╭", "╮", "╯", "╰" },
		color_devicons = true,
		use_less = true,
		set_env = { ["COLORTERM"] = "truecolor" }, -- default = nil,
		file_previewer = require("telescope.previewers").vim_buffer_cat.new,
		grep_previewer = require("telescope.previewers").vim_buffer_vimgrep.new,
		qflist_previewer = require("telescope.previewers").vim_buffer_qflist.new,
		-- Developer configurations: Not meant for general override
		buffer_previewer_maker = require("telescope.previewers").buffer_previewer_maker,
		mappings = {
			n = { ["q"] = ACTIONS.close },
			i = {
				["<esc>"] = ACTIONS.close,
			},
		},
	},

	extensions_list = { "themes", "terms" },
})

-- telescope-config.lua
local M = {}

M.project_files = function()
	local ok = pcall(require("telescope.builtin").git_files, {
		show_untracked = true,
	})
	if not ok then
		require("telescope.builtin").find_files({
			hidden = true,
		})
	end
end

M.grep = function()
	local ok = pcall(require("telescope.builtin").live_grep, {
		cwd = vim.lsp.get_active_clients()[1].config.root_dir
	})
end

vim.api.nvim_set_keymap(
	"n",
	"<Leader>fi",
	"<CMD>lua require'wesbragagt._telescope'.project_files()<CR>",
	{ noremap = true, silent = true }
)
vim.api.nvim_set_keymap(
	"n",
	"<Leader>fg",
	"<CMD>lua require'wesbragagt._telescope'.grep()<CR>",
	{ noremap = true, silent = true }
)

-- load extensions
pcall(function()
	for _, ext in ipairs(options.extensions_list) do
		telescope.load_extension(ext)
	end
end)

return M
