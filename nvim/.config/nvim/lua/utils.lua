local M = {}
Default_options = { noremap = true, silent = true }

function M.nnoremap(keymap, command)
	vim.api.nvim_set_keymap("n", keymap, command, Default_options)
end

function M.tnoremap(keymap, command)
	vim.api.nvim_set_keymap("t", keymap, command, Default_options)
end

function M.xnoremap(keymap, command)
	vim.api.nvim_set_keymap("x", keymap, command, Default_options)
end

function M.vnoremap(keymap, command)
	vim.api.nvim_set_keymap("v", keymap, command, Default_options)
end

return M
