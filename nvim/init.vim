set path+=**
" Nice menu when typing `:find *.py`
set wildmode=longest,list,full
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
set smartindent
set smartcase
set expandtab
set scrolloff=8
set number
set autochdir
set colorcolumn=80
call plug#begin()
Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}  " We recommend updating the parsers on update
Plug 'akinsho/toggleterm.nvim'
Plug 'tpope/vim-fugitive'
Plug 'tpope/vim-commentary'
Plug 'vim-airline/vim-airline'
Plug 'leafgarland/typescript-vim'
Plug 'preservim/nerdtree'
Plug 'moll/vim-node'
Plug 'ryanoasis/vim-devicons'
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
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'
Plug 'stsewd/fzf-checkout.vim'
let g:fsf_layout = {'window': {'width': 0.8, 'height': 0.8}}
let $FZF_DEFAULT_OPTS='--reverse'

Plug 'neoclide/coc.nvim', {'branch': 'release'}
let g:coc_global_extensions = [
  \ 'coc-tsserver',
  \ 'coc-yaml',
  \ 'coc-docker',
  \ 'coc-sh',
  \ 'coc-go'
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
colorscheme gruvbox
let g:gruvbox_bold = 0
" Visual selection highlight color #B4D7FE
hi Visual  guifg=#000000 guibg=#B4D7FE gui=none
" Formatting selected code.
xmap <leader>f  <Plug>(coc-format-selected)
nmap <leader>f  <Plug>(coc-format-selected)
" Add `:Format` command to format current buffer.
command! -nargs=0 Format :call CocAction('format')
" import module on cursor
nnoremap <leader>. :CocFix<CR>
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
nnoremap <leader>ff <cmd>Telescope find_files<cr>
nnoremap <leader>fg <cmd>Telescope live_grep<cr>
nnoremap <leader>fb <cmd>Telescope buffers<cr>
nnoremap <leader>fh <cmd>Telescope help_tags<cr>
nnoremap <C-f> :Rg 
nnoremap <leader>pt :NERDTreeToggle<CR>
nnoremap <silent> K :call CocAction('doHover')<CR>
" use regular escape in terminal mode
tnoremap <Esc> <C-\><C-n><CR>
" navigate between split panels
map <leader>h :wincmd h<CR>
map <leader>j :wincmd j<CR>
map <leader>k :wincmd k<CR>
map <leader>l :wincmd l<CR>
" go to definition
nmap <silent> gd <Plug>(coc-definition)
nmap <silent> gy <Plug>(coc-type-definition)
nmap <silent> gi <Plug>(coc-implementation)
nmap <silent> gr <Plug>(coc-references)
" Git stuff
nmap <leader>gs :G<CR>
nnoremap <leader>gc :GCheckout<CR>
" open this configuration file in split from anywhere
command! ConfigVim vsp ~/.dotfiles/nvim/init.vim
nnoremap <leader>co :ConfigVim<CR>
" toggle between uppercase and lowercase and move cursor to the end 
nnoremap <leader>to g~iwe<CR>
" run ts-node on the current file
nnoremap <leader>ts :!ts-node %<CR>
" run go on the current file
nnoremap <leader>go :!go run %<CR>
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
