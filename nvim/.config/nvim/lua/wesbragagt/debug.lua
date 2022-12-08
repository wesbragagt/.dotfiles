local dap_ok, dap = pcall(require, "dap")
local nnoremap = require("utils").nnoremap

if not dap_ok then
	return
end

local dapui_ok, dapui = pcall(require, "dapui")

if not dapui_ok then
	return
end

dapui.setup({
	icons = { expanded = "▾", collapsed = "▸" },
	mappings = {
		-- Use a table to apply multiple mappings
		expand = { "<CR>", "<2-LeftMouse>" },
		open = "o",
		remove = "d",
		edit = "e",
		repl = "r",
		toggle = "t",
	},
	-- Expand lines larger than the window
	-- Requires >= 0.7
	expand_lines = vim.fn.has("nvim-0.7"),
	-- Layouts define sections of the screen to place windows.
	-- The position can be "left", "right", "top" or "bottom".
	-- The size specifies the height/width depending on position. It can be an Int
	-- or a Float. Integer specifies height/width directly (i.e. 20 lines/columns) while
	-- Float value specifies percentage (i.e. 0.3 - 30% of available lines/columns)
	-- Elements are the elements shown in the layout (in order).
	-- Layouts are opened in order so that earlier layouts take priority in window sizing.
	layouts = {
		{
			elements = {
				"breakpoints",
				"watches",
			},
			size = 0.40,
			position = "left",
		},
		{
			elements = {
				-- Elements can be strings or table with id and size keys.
				"console",
			},
			size = 0.20,
			position = "right",
		},
	},
	floating = {
		max_height = nil, -- These can be integers or a float between 0 and 1.
		max_width = nil, -- Floats will be treated as percentage of your screen.
		border = "single", -- Border style. Can be "single", "double" or "rounded"
		mappings = {
			close = { "q", "<Esc>" },
		},
	},
	windows = { indent = 1 },
	render = {
		max_type_length = nil, -- Can be integer or nil.
	},
})

local dap_virtual_text_ok, dap_virtual_text = pcall(require, "nvim-dap-virtual-text")

if not dap_virtual_text_ok then
	return
end

dap_virtual_text.setup({})

local dap_vscode_js_ok, dap_vscode_js = pcall(require, "dap-vscode-js")

if not dap_vscode_js_ok then
	return
end

dap_vscode_js.setup({
	adapters = { "pwa-node", "pwa-chrome", "pwa-msedge", "node-terminal", "pwa-extensionHost" }, -- which adapters to register in nvim-dap
})

for _, language in ipairs({ "typescript", "javascript" }) do
	dap.configurations[language] = {
		{
			type = "pwa-node",
			cwd = "${workspaceFolder}",
			request = "launch",
			name = "Nest Debug",
			runtimeExecutable = "yarn",
			runtimeArgs = {
				"run",
				"start:debug",
				"--",
				"--inspect-brk",
			},
			console = "integratedTerminal",
			restart = true,
			protocol = "auto",
			port = 9229,
			autoAttachChildProcesses = true,
		},
		{
			name = "Debug Jest Tests",
			type = "pwa-node",
			request = "launch",
			cwd = "${workspaceFolder}",
			sourceMaps = "inline",
			skipFiles = { "<node_internals>/**" },
			runtimeExecutable = "yarn",
			runtimeArgs = {
				"--inspect-brk",
				"jest",
				"--runInBand",
				"--no-cache",
				"--no-collect-coverage",
				"--test-timeout=0",
				"--force-exit",
				"--findRelatedTests",
				"${file}",
			},
			console = "integratedTerminal",
			internalConsoleOptions = "neverOpen",
		},
	}
end

vim.fn.sign_define("DapBreakpoint", { text = "🛑", texthl = "", linehl = "", numhl = "" })
vim.fn.sign_define("DapBreakpointRejected", { text = "🔵", texthl = "", linehl = "", numhl = "" })
vim.fn.sign_define("DapStopped", { text = "⏸️", texthl = "", linehl = "", numhl = "" })

dap.set_log_level("DEBUG")

-- maps
nnoremap("<leader>9", function()
	dap.toggle_breakpoint()
end)
nnoremap("<leader>0", function()
	dap.continue()
end)
nnoremap("<leader>du", function()
	dapui.toggle({})
end)
nnoremap("<leader>[", function()
	require("dap.breakpoints").clear()
end)

nnoremap("H", function()
	dapui.eval()
end)
