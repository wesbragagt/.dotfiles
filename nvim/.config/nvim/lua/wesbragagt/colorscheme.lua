local IsTransparent = false
local utils = require('utils')
local nnoremap = utils.nnoremap

local function turn_background_transparent()
  vim.cmd [[
      highlight Normal guibg=none
      highlight NonText guibg=none
      highlight Normal ctermbg=none
      highlight NonText ctermbg=none
    ]]
end


local function color_my_pencils(transparent)
  local _transparent = transparent or false

  local colorscheme = "kanagawa"
  local ok, error = pcall(function()
    vim.cmd(string.format('colorscheme %s', colorscheme))
  end)

  if not ok then
    print(string.format('Error loading colorscheme: %s', error))
    vim.cmd [[colorscheme default]]
  end

  -- Hide all semantic highlights
  for _, group in ipairs(vim.fn.getcompletion("@lsp", "highlight")) do
    vim.api.nvim_set_hl(0, group, {})
  end

  if _transparent then
    turn_background_transparent()
  end
end

local function init_colorscheme()
  color_my_pencils(IsTransparent)
end

init_colorscheme()

nnoremap('<leader>tb', function()
  IsTransparent = not IsTransparent
  color_my_pencils(IsTransparent)
end)
