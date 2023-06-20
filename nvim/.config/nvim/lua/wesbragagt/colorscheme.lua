vim.cmd([[
  if (has("termguicolors"))
    set termguicolors
  endif
  try
  colorscheme kanagawa-wave
  catch /^Vim\%((\a\+)\)\=:E185/
    colorscheme default
  endtry
]])

-- Hide all semantic highlights
for _, group in ipairs(vim.fn.getcompletion("@lsp", "highlight")) do
  vim.api.nvim_set_hl(0, group, {})
end
