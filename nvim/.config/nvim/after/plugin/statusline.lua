local status_ok, statusline = pcall(require, "lualine")

if not status_ok then
	return
end

statusline.setup({
	options = {
		icons_enabled = false,
		theme = "auto",
		component_separators = { left = "", right = "" },
		section_separators = { left = "", right = "" },
		disabled_filetypes = {
			statusline = {},
			winbar = {},
		},
		ignore_focus = {},
		always_divide_middle = true,
		globalstatus = false,
		refresh = {
			statusline = 500,
			tabline = 500,
			winbar = 500,
		},
	},
	sections = {
		lualine_a = {"branch" },
		lualine_b = { "diff", "diagnostics",{"filename", path = 3} },
		lualine_c = {},
		lualine_x = {},
		lualine_y = {},
		lualine_z = {},
	},
	inactive_sections = {
		lualine_a = {},
		lualine_b = {},
		lualine_c = {},
		lualine_x = {},
		lualine_y = {},
		lualine_z = {},
	},
	tabline = {},
	winbar = {
		lualine_a = {},
		lualine_b = {},
		lualine_c = {},
	},
	inactive_winbar = {
		lualine_c = {},
	},
	extensions = {},
})
