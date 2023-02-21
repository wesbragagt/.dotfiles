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

function M.inoremap(keymap, command, opts)
	vim.keymap.set("i", keymap, command, extend_options(opts))
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

function M.is_git_repo()
	vim.fn.system("git rev-parse --is-inside-work-tree")

	return vim.v.shell_error == 0
end

function M.get_git_root()
	local dot_git_path = vim.fn.finddir(".git", ".;")
	return vim.fn.fnamemodify(dot_git_path, ":h")
end

function M.print_table(t, indent)
	indent = indent or 0
	for k, v in pairs(t) do
		formatting = string.rep(" ", indent) .. k .. ": "
		if type(v) == "table" then
			print(formatting)
			M.print_table(v, indent + 2)
		else
			print(formatting .. tostring(v))
		end
	end
end

function M.get_git_root_with_fallback()
	vim.fn.system("git rev-parse --is-inside-work-tree")

	if not vim.v.shell_error == 0 then
		-- get current buffer path as fallback
		local cwd = vim.loop.cwd()
		return cwd
	end

	local dot_git_path = vim.fn.finddir(".git", ".;")
	return vim.fn.fnamemodify(dot_git_path, ":h")
end

return M
