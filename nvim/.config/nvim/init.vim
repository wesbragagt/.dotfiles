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

if executable("rg")
    set grepprg=rg\ --vimgrep\ --no-heading
    set grepformat=%f:%l:%c:%m,%f:%l:%m
endif

augroup quickfix
    autocmd!
    autocmd QuickFixCmdPost [^l]* cwindow
    autocmd QuickFixCmdPost l* lwindow
  augroup END

call plug#begin('~/.vim/plugged')
Plug 'airblade/vim-rooter'
" Treesitter
Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}  " We recommend updating the parsers on update
" LSP
Plug 'neovim/nvim-lspconfig'
Plug 'williamboman/nvim-lsp-installer'
Plug 'ahmedkhalf/project.nvim'
Plug 'hrsh7th/cmp-nvim-lsp'
Plug 'hrsh7th/cmp-buffer'
Plug 'hrsh7th/nvim-cmp'
" Diagnostics
Plug 'folke/trouble.nvim'
Plug 'folke/lsp-colors.nvim'

" For vsnip user.
Plug 'hrsh7th/cmp-vsnip'
Plug 'hrsh7th/vim-vsnip'
Plug 'glepnir/lspsaga.nvim'
Plug 'akinsho/toggleterm.nvim'
" Buffer
Plug 'akinsho/bufferline.nvim'
" Git
Plug 'tpope/vim-fugitive'
" Comments
Plug 'tpope/vim-commentary'
" Status
Plug 'vim-airline/vim-airline'
Plug 'preservim/nerdtree'
Plug 'kyazdani42/nvim-web-devicons' " Recommended (for coloured icons)
Plug 'ryanoasis/vim-devicons'
Plug 'morhetz/gruvbox'
Plug 'jiangmiao/auto-pairs' "this will auto close ( [ {
Plug 'nvim-lua/plenary.nvim'
Plug 'nvim-telescope/telescope.nvim'
Plug 'nvim-telescope/telescope-fzf-native.nvim', { 'do': 'make' }
Plug 'styled-components/vim-styled-components', { 'branch': 'main' }
Plug 'jparise/vim-graphql'
Plug 'iamcco/markdown-preview.nvim', { 'do': 'cd app && yarn install'  }

" Formatting
Plug 'mhartington/formatter.nvim'
call plug#end()
lua require("wesbragagt")
