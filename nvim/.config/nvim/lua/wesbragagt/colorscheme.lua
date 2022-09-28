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
  colorscheme tokyonight
  catch /^Vim\%((\a\+)\)\=:E185/
    colorscheme default
  endtry
]])
