local jester_ok, jester = pcall(require, "jester")

if not jester_ok then
	return
end

jester.setup({
	cmd = "yarn test '$result' -- $file", -- run command
	identifiers = { "test", "it" }, -- used to identify tests
	prepend = { "describe" }, -- prepend describe blocks
	expressions = { "call_expression" }, -- tree-sitter object used to scan for tests/describe blocks
	path_to_jest_run = "jest", -- used to run tests
	path_to_jest_debug = "./node_modules/.bin/jest", -- used for debugging
	terminal_cmd = ":vsplit | terminal", -- used to spawn a terminal for running tests, for debugging refer to nvim-dap's config
	dap = {
		type = "pwa-node",
		request = "launch",
		name = "Debug Jest Tests",
		skipFiles = { "<node_internals>/**" },
		trace = true, -- include debugger info
		cwd = vim.fn.getcwd(),
		runtimeArgs = { "--inspect-brk", "$path_to_jest", "--no-coverage", "-t", "$result", "--", "$file" },
		args = { "--no-cache" },
		sourceMaps = "inline",
		protocol = "inspector",
		console = "integratedTerminal",
		port = 9229,
		disableOptimisticBPs = true,
	},
})

local nnoremap = require("utils").nnoremap

nnoremap("<leader>tt", function()
	jester.run()
end)
nnoremap("<leader>t_", function()
	jester.run_last()
end)
nnoremap("<leader>tf", function()
	jester.run_file()
end)
nnoremap("<leader>d_", function()
	jester.debug_last()
end)
nnoremap("<leader>df", function()
	jester.debug_file()
end)
nnoremap("<leader>dq", function()
	jester.terminate()
end)
nnoremap("<leader>dd", function()
	jester.debug()
end)