local ok, harpoon = pcall(require, "harpoon")

if not ok then
	return
end

harpoon.setup({
	menu = {
		width = vim.api.nvim_win_get_width(0) - 4,
	},
	global_settings = {
		-- sets the marks upon calling `toggle` on the ui, instead of require `:w`.
		save_on_toggle = false,

		-- saves the harpoon file upon every change. disabling is unrecommended.
		save_on_change = true,

		-- sets harpoon to run the command immediately as it's passed to the terminal when calling `sendCommand`.
		enter_on_sendcmd = false,

		-- closes any tmux windows harpoon that harpoon creates when you close Neovim.
		tmux_autoclose_windows = false,

		-- filetypes that you want to prevent from adding to the harpoon list menu.
		excluded_filetypes = { "harpoon" },

		-- set marks specific to each git branch inside git repository
		mark_branch = false,
	},
})

local nnoremap = require("utils").nnoremap

nnoremap("<leader>'", function()
	require("harpoon.mark").add_file()
end)
nnoremap("<leader>m", function()
	require("harpoon.ui").toggle_quick_menu()
end, {nowait = true})

nnoremap("<leader>1", function()
	require("harpoon.ui").nav_file(1)
end)
nnoremap("<leader>2", function()
	require("harpoon.ui").nav_file(2)
end)
nnoremap("<leader>3", function()
	require("harpoon.ui").nav_file(3)
end)
nnoremap("<leader>4", function()
	require("harpoon.ui").nav_flle(4)
end)
