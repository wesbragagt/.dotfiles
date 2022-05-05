set autoread
set path+=**
" Nice menu when typing `:find *.py`
set wildmode=full,list
set wildmenu
" Ignore files
set wildignore+=*build/*
set wildignore+=*dist/*
set wildignore+=**/coverage/*
set wildignore+=**/.git/*
set wildignore+=**/node_modules/** 
if executable("rg")
    set grepprg=rg\ --vimgrep\ --no-heading
    set grepformat=%f:%l:%c:%m,%f:%l:%m
endif
"Open quickfix list after find,grep
augroup quickfix
    autocmd!
    autocmd QuickFixCmdPost [^l]* cwindow
    autocmd QuickFixCmdPost l* lwindow
  augroup END

"Folds
set foldenable
set foldmethod=indent
" Sets to open all folds by default when opening a file
set foldlevelstart=99

set fileencoding=utf-8
set conceallevel=0 "so that ``is visible in markdown files"
" set clipboard^=unnamed,unnamedplus
set norelativenumber
set completeopt=menuone,noselect
set wrap
set timeoutlen=1000 "time to wait for a mapped sequence to complete (in milliseconds)"
set updatetime=300 "faster autocompletion"
" sets vsp to split right by default
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
