local ok, fzf = pcall(require, "fzf-lua")

if not ok then
  return
end

local my_utils = require("utils")

local function project_files()
  local excluded = { 'node_modules', '.git' }
  local excluded_cmd = ''
  for _, value in pairs(excluded) do
    excluded_cmd = excluded_cmd .. string.format('--exclude %s ', value)
  end
  fzf.files({
    cwd = my_utils.get_git_root_with_fallback(),
    cmd = string.format('fd --type file -H %s', excluded_cmd)
  })
end

local function live_grep()
  local excluded = { '!.git/*', '!node_modules/*' }
  local excluded_cmd = ''
  for _, value in pairs(excluded) do
    excluded_cmd = excluded_cmd .. string.format('--glob %s ', value)
  end

  fzf.live_grep({
    cwd = my_utils.get_git_root_with_fallback(),
    cmd = string.format('rg --column --smart-case --hidden --no-require-git --fixed-strings %s', excluded_cmd),
  })
end

-- mappings
local nnoremap = require("utils").nnoremap

nnoremap("<leader><space>", fzf.buffers)
nnoremap("<leader>sf", project_files)
nnoremap("<leader>sg", live_grep)
nnoremap("<leader>sd", fzf.diagnostics_document)
