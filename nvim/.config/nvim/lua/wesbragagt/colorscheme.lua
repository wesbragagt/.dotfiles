-- todo migrate to lua syntax
vim.cmd([[
  if (has("termguicolors"))
    set termguicolors
  endif
  try
    colorscheme nightfox
  catch /^Vim\%((\a\+)\)\=:E185/
    colorscheme default
    set background=dark
  endtry
]])
