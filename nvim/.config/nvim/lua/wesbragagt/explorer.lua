-- Autorefresh when focusing
vim.cmd([[
autocmd BufEnter NERD_tree_* | execute 'normal R'
let g:NERDTreeWinSize=30
let g:NERDTreeWinPos = "right"
let NERDTreeShowHidden=1
let mapleader = ' '

nnoremap <leader>pt :NERDTreeToggle<CR>
]])
