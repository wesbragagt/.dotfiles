-- todo migrate to lua syntax
vim.cmd([[
  if (has("termguicolors"))
    set termguicolors
  endif
  try
    colorscheme darkplus
  catch /^Vim\%((\a\+)\)\=:E185/
    colorscheme default
    set background=dark
  endtry
]])
