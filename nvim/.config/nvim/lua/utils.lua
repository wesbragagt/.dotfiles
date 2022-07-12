local M = {}

local function extend_options(opts)
	local options = {}
	if opts then
		options = vim.tbl_extend("force", options, opts)
	end
	return options
end

function M.nnoremap(keymap, command, opts)
	vim.keymap.set("n", keymap, command, extend_options(opts))
end

function M.tnoremap(keymap, command, opts)
	vim.keymap.set("t", keymap, command, extend_options(opts))
end

function M.xnoremap(keymap, command, opts)
	vim.keymap.set("x", keymap, command, extend_options(opts))
end

function M.vnoremap(keymap, command, opts)
	vim.keymap.set("v", keymap, command, extend_options(opts))
end

return M
