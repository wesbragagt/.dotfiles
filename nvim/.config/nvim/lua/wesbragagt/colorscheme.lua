vim.cmd([[
  if (has("termguicolors"))
    set termguicolors
  endif
  try
  colorscheme tokyonight-moon
  catch /^Vim\%((\a\+)\)\=:E185/
    colorscheme default
  endtry
]])
