local ok, spectre = pcall(require, "spectre")

if not ok then
	return
end

spectre.setup({
	find_engine = {
		-- rg is map with finder_cmd
		["rg"] = {
			cmd = "rg",
			-- default args
			args = {
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
			options = {
				["ignore-case"] = {
					value = "--ignore-case",
					icon = "[I]",
					desc = "ignore case",
				},
				["hidden"] = {
					value = "--hidden",
					desc = "hidden file",
					icon = "[H]",
				},
				-- you can put any rg search option you want here it can toggle with
				-- show_option function
			},
		},
	},
	highlight = {
		ui = "String",
		search = "DiffChange",
		replace = "DiffDelete",
	},
})

local utils = require("utils")

utils.nnoremap("<leader>S", function()
	spectre.open({
		cwd = utils.get_git_root_with_fallback(),
	})
end)
utils.nnoremap("<leader>sw", function()
	spectre.open_visual({ select_word = true })
end)

utils.nnoremap("<leader>s", spectre.open_visual)
utils.nnoremap("<leader>sp", spectre.open_file_search)
