local ok, spectre = pcall(require, "spectre")

if not ok then
	return
end

spectre.setup({
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
		cwd = utils.get_git_root(),
	})
end)
utils.nnoremap("<leader>sw", function()
	spectre.open_visual({ select_word = true })
end)

utils.nnoremap("<leader>s", spectre.open_visual)
utils.nnoremap("<leader>sp", spectre.open_file_search)
