local M = {}

function M.nnoremap(keymap, command, opts)
	local options = { noremap = true }
	if opts then
		options = vim.tbl_extend("force", options, opts)
	end
	vim.keymap.set("n", keymap, command, options)
end

function M.tnoremap(keymap, command, opts)
	local options = { noremap = true }
	if opts then
		options = vim.tbl_extend("force", options, opts)
	end
	vim.keymap.set("t", keymap, command, options)
end

function M.xnoremap(keymap, command, opts)
	local options = { noremap = true }
	if opts then
		options = vim.tbl_extend("force", options, opts)
	end
	vim.keymap.set("x", keymap, command, options)
end

function M.vnoremap(keymap, command, opts)
	local options = { noremap = true }
	if opts then
		options = vim.tbl_extend("force", options, opts)
	end
	vim.keymap.set("v", keymap, command, options)
end

return M
