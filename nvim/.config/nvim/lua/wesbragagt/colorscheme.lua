local ok, theme = pcall(require, "catppuccin")

if not ok then
	return
end

theme.setup()

vim.cmd([[
  if (has("termguicolors"))
    set termguicolors
  endif
  try
    let g:catppuccin_flavour = "mocha"
    colorscheme catppuccin
  catch /^Vim\%((\a\+)\)\=:E185/
    colorscheme default
    set background=dark
  endtry
]])
