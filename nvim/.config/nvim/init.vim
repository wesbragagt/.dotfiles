call plug#begin('~/.vim/plugged')
Plug 'preservim/vimux'
Plug 'christoomey/vim-tmux-navigator'
Plug 'airblade/vim-rooter'
" Boost startup 
Plug 'nathom/filetype.nvim'
Plug 'lewis6991/impatient.nvim'
" Treesitter
Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}  " We recommend updating the parsers on update
" LSP
Plug 'neovim/nvim-lspconfig'
Plug 'williamboman/nvim-lsp-installer'
Plug 'hrsh7th/cmp-nvim-lsp'
Plug 'hrsh7th/cmp-buffer'
Plug 'hrsh7th/cmp-path'
Plug 'hrsh7th/cmp-cmdline'
Plug 'hrsh7th/nvim-cmp'
Plug 'hrsh7th/cmp-nvim-lua'
Plug 'L3MON4D3/LuaSnip'
Plug 'saadparwaiz1/cmp_luasnip'
Plug 'folke/lua-dev.nvim'
" Diagnostics
Plug 'folke/trouble.nvim'
Plug 'folke/lsp-colors.nvim'

" For vsnip user.
Plug 'rafamadriz/friendly-snippets'
Plug 'hrsh7th/cmp-vsnip'
Plug 'hrsh7th/vim-vsnip'
"@deprecated Plug 'akinsho/toggleterm.nvim'
" Git
Plug 'tpope/vim-fugitive'
Plug 'f-person/git-blame.nvim'
" Comments
Plug 'tpope/vim-commentary'
" Status
Plug 'nvim-lualine/lualine.nvim'
Plug 'lewis6991/gitsigns.nvim'
Plug 'preservim/nerdtree'
Plug 'ryanoasis/vim-devicons'

" Colorscheme

Plug 'morhetz/gruvbox'
Plug 'lunarvim/colorschemes'

Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'

Plug 'jiangmiao/auto-pairs' "this will auto close ( [ {
Plug 'nvim-lua/popup.nvim'
Plug 'nvim-lua/plenary.nvim'
Plug 'sindrets/diffview.nvim'
Plug 'nvim-telescope/telescope.nvim'
Plug 'iamcco/markdown-preview.nvim', { 'do': 'cd app && yarn install'  }
" Bufferline
Plug 'kyazdani42/nvim-web-devicons' " Recommended (for coloured icons)
" Plug 'ryanoasis/vim-devicons' Icons without colours
Plug 'akinsho/bufferline.nvim'
" Formatting
Plug 'mhartington/formatter.nvim'

" Tests
Plug 'vim-test/vim-test'
call plug#end()
let g:rooter_patterns = ['.git', 'node_modules']
" To toggle between automatic and manual behaviour, use :RooterToggle. or
" <leader>/
let g:rooter_manual_only = 1
" Git Blame
let g:gitblame_enabled = 0
lua require("wesbragagt")
