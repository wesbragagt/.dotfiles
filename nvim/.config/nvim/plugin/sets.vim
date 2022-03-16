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

"Use 24-bit (true-color) mode in Vim/Neovim when outside tmux.
"If you're using tmux version 2.2 or later, you can remove the outermost $TMUX check and use tmux's 24-bit color support
"(see < http://sunaku.github.io/tmux-24bit-color.html#usage > for more information.)
if (empty($TMUX))
  if (has("nvim"))
  "For Neovim 0.1.3 and 0.1.4 < https://github.com/neovim/neovim/pull/2198 >
  let $NVIM_TUI_ENABLE_TRUE_COLOR=1
  endif
  "For Neovim > 0.1.5 and Vim > patch 7.4.1799 < https://github.com/vim/vim/commit/61be73bb0f965a895bfb064ea3e55476ac175162 >
  "Based on Vim patch 7.4.1770 (`guicolors` option) < https://github.com/vim/vim/commit/8a633e3427b47286869aa4b96f2bfc1fe65b25cd >
  " < https://github.com/neovim/neovim/wiki/Following-HEAD#20160511 >
  if (has("termguicolors"))
    set termguicolors
  endif
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
set clipboard^=unnamed,unnamedplus
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
set autochdir "allow the mouse to be used in neovim"
set colorcolumn=80
set iskeyword+=- 
set background=dark 
set cursorline
