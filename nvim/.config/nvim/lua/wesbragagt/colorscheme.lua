vim.cmd([[
  if (has("termguicolors"))
    set termguicolors
  endif
  try
  colorscheme catppuccin-mocha
  catch /^Vim\%((\a\+)\)\=:E185/
    colorscheme default
  endtry
]])
