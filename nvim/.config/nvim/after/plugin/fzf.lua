local ok, fzf = pcall(require, "fzf-lua")

if not ok then
  return
end

local my_utils = require("utils")

-- Falling back to find_files if git_files can't find a .git directory
local function project_files()
  local cwd = my_utils.get_git_root_with_fallback()
  local excluded_folders = { 'node_modules', '.git' }
  local excluded = ''
  for _, value in pairs(excluded_folders) do
    excluded = excluded .. ' --exclude' .. ' ' .. value
  end
  local cmd = string.format('fd --type file -H %s', excluded)
  fzf.files({ cmd, cwd = my_utils.get_git_root_with_fallback() })
end

local function live_grep()
  local excluded = { '!.git/*', '!node_modules/*' }
  local excluded_cmd = ''
  for _, value in pairs(excluded) do
    excluded_cmd = excluded_cmd .. string.format('--glob %s ', value)
  end

  fzf.live_grep({
    cwd = my_utils.get_git_root_with_fallback(),
    cmd = string.format('rg --column --smart-case --hidden --no-require-git --follow %s', excluded_cmd),
  })
end

-- mappings
local nnoremap = require("utils").nnoremap

nnoremap("<leader><space>", fzf.buffers)
nnoremap("<leader>sf", project_files)
nnoremap("<leader>sg", live_grep)
nnoremap("<leader>sd", fzf.diagnostics_document)
