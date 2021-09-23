set autoread
set path+=**
" Nice menu when typing `:find *.py`
set wildmode=full,list
set wildmenu
" Ignore files
set wildignore+=*build/*
set wildignore+=*dist/*
set wildignore+=**/coverage/*
set wildignore+=**/node_modules/*
set wildignore+=**/.git/*
set norelativenumber
set wrap
set updatetime=300
" sets vsp to split right by default
set splitright
set hidden
set mouse=a
set noswapfile
set nobackup
set undodir=~/.vim/undodir
set undofile
set incsearch
set termguicolors
set showcmd
set tabstop=2
set softtabstop=2
set shiftwidth=2
set smartcase
set noerrorbells
set smartindent
set expandtab
set scrolloff=8
set number
set autochdir
set colorcolumn=80
" transparent background
hi normal guibg=000000
call plug#begin('~/.vim/plugged')
Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}  " We recommend updating the parsers on update
Plug 'akinsho/toggleterm.nvim'
Plug 'tpope/vim-fugitive'
Plug 'tpope/vim-commentary'
Plug 'vim-airline/vim-airline'
Plug 'leafgarland/typescript-vim'
Plug 'preservim/nerdtree'
Plug 'moll/vim-node'
Plug 'ryanoasis/vim-devicons'
Plug 'kyazdani42/nvim-web-devicons' " Recommended (for coloured icons)
Plug 'morhetz/gruvbox'
Plug 'jiangmiao/auto-pairs' "this will auto close ( [ {
" these two plugins will add highlighting and indenting to JSX and TSX files.
Plug 'yuezk/vim-js'
Plug 'HerringtonDarkholme/yats.vim'
Plug 'maxmellon/vim-jsx-pretty'
Plug 'mxw/vim-jsx'
Plug 'pangloss/vim-javascript'
Plug 'nvim-lua/plenary.nvim'
Plug 'nvim-telescope/telescope.nvim'
Plug 'neoclide/coc.nvim', {'branch': 'release'}
let g:coc_global_extensions = [
  \ 'coc-html',
  \ 'coc-tsserver',
  \ 'coc-yaml',
  \ 'coc-docker',
  \ 'coc-sh',
  \ 'coc-go',
  \ 'coc-tailwindcss',
  \ 'coc-lua',
  \ 'coc-vimlsp'
  \ ]
Plug 'styled-components/vim-styled-components', { 'branch': 'main' }
Plug 'jparise/vim-graphql'
call plug#end()
lua <<EOF
require'nvim-treesitter.configs'.setup { highlight = { enable = true }, incremental_selection = { enable = true }, textobjects = { enable = true }}
require'toggleterm'.setup{
open_mapping=[[<c-\>]],
insert_mappings = false
}
require('telescope').setup{ defaults = { file_ignore_patterns = {"node_modules", ".git"} } }

EOF

set background=dark
let g:gruvbox_contrast_dark = 'hard'
let g:gruvbox_bold = 0
colorscheme gruvbox
hi Visual  guifg=#000000 guibg=#B4D7FE gui=none
" Add `:Format` command to format current buffer.
command! -nargs=0 Format :call CocAction('format')
" import module on cursor
nnoremap <C-Space> :CocAction<CR>
if isdirectory('./node_modules') && isdirectory('./node_modules/prettier')
  let g:coc_global_extensions += ['coc-prettier']
endif

if isdirectory('./node_modules') && isdirectory('./node_modules/eslint')
  let g:coc_global_extensions += ['coc-eslint']
endif

let mapleader = ' '
" nnore --> Normal mode, no recursive execution
nnoremap <leader><Enter> :so %<CR>
nnoremap <leader>rn :!node %<CR>
" Project view open
let g:NERDTreeWinPos = "right"
let NERDTreeShowHidden=1
" Find files using Telescope command-line sugar.
nnoremap <leader>ff <cmd>Telescope find_files<CR>
nnoremap <leader>fg <cmd>Telescope live_grep<CR>
nnoremap <leader>fb <cmd>Telescope buffers<CR>
nnoremap <leader>fgb <cmd>Telescope git_branches<CR>
nnoremap <C-f> :Rg 
nnoremap <leader>pt :NERDTreeToggle<CR>
nnoremap <silent> K :call CocAction('doHover')<CR>
" use regular escape in terminal mode
tnoremap <Esc> <C-\><C-n><CR>
" navigate between split panels
nnoremap <leader>h :wincmd h<CR>
nnoremap <leader>j :wincmd j<CR>
nnoremap <leader>k :wincmd k<CR>
nnoremap <leader>l :wincmd l<CR>
" go to definition
nmap <silent> gd <Plug>(coc-definition)
nmap <silent> gy <Plug>(coc-type-definition)
nmap <silent> gi <Plug>(coc-implementation)
nmap <silent> gr <Plug>(coc-references)
" Git stuff
" commit
" left pick merge
nmap <leader>gh :diffget //2<CR>
" right pick merge
nmap <leader>gl :diffget //3<CR>
" Status
nmap <leader>gs :G<CR>
" open this configuration file in split from anywhere
command! ConfigVim vsp ~/.dotfiles/nvim/.config/nvim/init.vim
nnoremap <leader>co :ConfigVim<CR>
" toggle between uppercase and lowercase 
nnoremap <leader>to g~w<CR>
" run ts-node on the current file
nnoremap <leader>ts :!ts-node %<CR>
" run go on the current file
nnoremap <leader>go :!go run %<CR>
" run current shell file 
nnoremap <leader>sh :!zsh %<CR>
" CoC diagnostic
nnoremap <leader>di :CocDiagnostics<CR>
" quickfix navigation
nnoremap <leader>qn :cnext<CR>
nnoremap <leader>qp :cprev<CR>
nnoremap <leader>qo :copen<CR>
" location list navigation
nnoremap <leader>ln :lnext<CR>
nnoremap <leader>lp :lprev<CR>
nnoremap <leader>lo :lopen<CR>
" Bufferline close current buffer
nnoremap <leader>x :bdelete<CR>
" Format shortcut
nnoremap <leader>fo :Format<CR>
nnoremap <leader>x :!chmod +x %<CR>

" simple command to copy all search matches to the clipboard
function! CopyMatches(reg)
  let hits = []
  %s//\=len(add(hits, submatch(0))) ? submatch(0) : ''/gne
  let reg = empty(a:reg) ? '+' : a:reg
  execute 'let @'.reg.' = join(hits, "\n") . "\n"'
endfunction
command! -register CopyMatches call CopyMatches(<q-reg>)
