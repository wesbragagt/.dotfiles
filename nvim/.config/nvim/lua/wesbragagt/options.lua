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

augroup quickfix
    autocmd!
    autocmd QuickFixCmdPost [^l]* cwindow
    autocmd QuickFixCmdPost l* lwindow
  augroup END


set foldenable
set foldmethod=indent

set foldlevelstart=99

set fileencoding=utf-8
set conceallevel=0 "so that ``is visible in markdown files"

set norelativenumber
set completeopt=menuone,noselect,noinsert
set wrap
set timeoutlen=1000 "time to wait for a mapped sequence to complete (in milliseconds)"
set updatetime=300 "faster autocompletion"

set splitright "force all horizontal splits to go below current window"
set splitbelow "force all vertical splits to go to the right of current window"
set cmdheight=1
set hidden
set mouse=a "allow the mouse to be used in neovim"
set noswapfile "dont create swap files"
set nobackup "dont create a backup"
set nowritebackup "if a file is being edited by another program (or was written to file while editing with another program), it is not allowed to be edited"
set undodir=~/.vim/undodir
set undofile "enable persistent undo"

set hlsearch "highlight all matches when search"
set showcmd
set tabstop=2 "insert 2 spaces for a tab"
set softtabstop=2
set shiftwidth=2 "the number of spaces inserted for each indentation"
set smartcase
set noerrorbells
set smartindent
set expandtab "convert tabs to spaces"
set scrolloff=8
set number "display line numbers"
set numberwidth=2 "line numbers width"
set autochdir 
set colorcolumn=120
set iskeyword+=- 
set background=dark 
set cursorline

set pumheight=15

autocmd TermOpen * setlocal nonumber norelativenumber
]])
