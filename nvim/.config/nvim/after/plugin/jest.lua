-- Run jest command on saving file and display diagnostics in a quickfix list
local ok, jest = pcall(require, "jest")
if not ok then
	return
end

jest.setup({
	init_type = "autocmd",
	jest_commands = { { ".*", "./node_modules/jest/bin/jest.js" } },
	root_markers = { ".git", "package.json" },
	pattern = {
		"**/__tests__/**.{js,jsx,ts,tsx}",
		"*.spec.{js,jsx,ts,tsx}",
		"*.test.{js,jsx,ts,tsx}",
	},
})

local nnoremap = require("utils").nnoremap

nnoremap("<leader>jo", function()
	vim.cmd(":JestStart")
end)
nnoremap("<leader>jc", function()
	vim.cmd(":JestStop")
end)
