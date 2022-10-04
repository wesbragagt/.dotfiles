local status_ok, statusline = pcall(require, "lualine")

if not status_ok then
	return
end

statusline.setup({
	options = {
		icons_enabled = false,
		theme = "onedark",
		component_separators = "|",
		section_separators = "",
	},
})
