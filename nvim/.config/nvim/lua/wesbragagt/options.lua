vim.cmd([[ 
set autoread
set path+=**

set wildmode=full,list
set wildmenu

set wildignore+=*build/*
set wildignore+=*dist/*
set wildignore+=**/coverage/*
set wildignore+=**/.git/*
set wildignore+=**/node_modules/** 
if executable("rg")
    set grepprg=rg\ --vimgrep\ --no-heading
    set grepformat=%f:%l:%c:%m,%f:%l:%m
endif
" open quickfix list as soon as items are inserted"
augroup quickfix
    autocmd!
    autocmd QuickFixCmdPost [^l]* cwindow
    autocmd QuickFixCmdPost l* lwindow
augroup END

" highlight on yank"
augroup highlight_yank
    autocmd!
    au TextYankPost * silent! lua vim.highlight.on_yank({higroup="IncSearch", timeout=150})
augroup END


set foldenable
set foldmethod=indent

set foldlevelstart=99

set fileencoding=utf-8

set timeoutlen=1000 "time to wait for a mapped sequence to complete (in milliseconds)"

set iskeyword+=- 

autocmd TermOpen * setlocal nonumber norelativenumber
]])

vim.o.completeopt="menuone,noselect,noinsert"
vim.o.wrap = true
vim.o.conceallevel=0 -- so that ``is visible in markdown files
vim.o.swapfile=false
vim.o.backup=false
vim.o.writebackup=false
vim.o.undodir="~/.vim/undodir"
vim.o.undofile=true -- enable persistent undo"

vim.o.errorbells = false

vim.o.scrolloff=8 -- scroll half of the page
vim.o.numberwidth=2

vim.o.autochdir = true
vim.o.relativenumber = true

vim.o.hidden = true -- preserve buffers
vim.o.splitright = true -- force all horizontal splits to go below current window
vim.o.splitbelow = true -- force all vertical splits to go to the right of current window

vim.o.hlsearch = true

vim.o.smartcase = true
vim.o.smartindent = true
vim.o.expandtab = true
vim.o.tabstop = 2
vim.o.softtabstop = 2
vim.o.shiftwidth = 2
vim.o.colorcolumn = 120

vim.o.ls = false -- last status bar
vim.o.ch = false -- command bar

vim.o.updatetime = 150
vim.o.pumheight = 15
