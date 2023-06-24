local ok, fzf = pcall(require, "fzf-lua")

if not ok then
	return
end

local my_utils = require("utils")

-- Falling back to find_files if git_files can't find a .git directory
local function project_files()
	if require("utils").is_git_repo() then
		fzf.git_files({ cmd = 'git ls-files --others --exclude="node_modules/"' })
	else
		fzf.find_files()
	end
end

local function live_grep()
	local opts = {}

	if my_utils.is_git_repo() then
		opts = {
			cwd = my_utils.get_git_root(),
		}
	end

	local available = pcall(fzf.live_grep, opts)
	if not available then
		return
	end
end

-- mappings
local nnoremap = require("utils").nnoremap

nnoremap("<leader><space>", fzf.buffers)
nnoremap("<leader>sf", project_files)
nnoremap("<leader>sg", live_grep)
nnoremap("<leader>sd", fzf.diagnostics_document)
