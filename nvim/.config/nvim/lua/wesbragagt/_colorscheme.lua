vim.cmd [[
try
  highlight Visual  guifg=#000000 guibg=#B4D7FE gui=none
  " transparent background
  highlight normal guibg=000000
  let g:gruvbox_contrast_dark = 'hard'
  let g:gruvbox_bold = 0
  let g:gruvbox_transparent_bg = 1
  colorscheme gruvbox 
catch /^Vim\%((\a\+)\)\=:E185/
  colorscheme default
endtry
  ]]
