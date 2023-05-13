vim.cmd([[
  if (has("termguicolors"))
    set termguicolors
  endif
  try
  colorscheme kanagawa
  catch /^Vim\%((\a\+)\)\=:E185/
    colorscheme default
  endtry
]])
