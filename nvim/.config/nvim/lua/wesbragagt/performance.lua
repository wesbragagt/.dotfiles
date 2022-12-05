local status_ok, filetype = pcall(require, "filetype")
if not status_ok then
	return
end

vim.g.did_load_filetypes = 1
filetype.setup({
	overrides = {
		extensions = {
			tf = "terraform",
			tfvars = "terraform",
			tfstate = "json",
		},
	},
})
-- Speed up neovim startup
require("impatient")
