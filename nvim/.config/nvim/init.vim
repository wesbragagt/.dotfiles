call plug#begin('~/.vim/plugged')
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
Plug 'akinsho/toggleterm.nvim'
" Git
Plug 'tpope/vim-fugitive'
" Comments
Plug 'tpope/vim-commentary'
" Status
Plug 'nvim-lualine/lualine.nvim'
Plug 'lewis6991/gitsigns.nvim'
Plug 'preservim/nerdtree'
Plug 'kyazdani42/nvim-web-devicons' " Recommended (for coloured icons)
Plug 'ryanoasis/vim-devicons'

" Colorscheme

Plug 'morhetz/gruvbox'
Plug 'lunarvim/colorschemes'

Plug 'jiangmiao/auto-pairs' "this will auto close ( [ {
Plug 'nvim-lua/popup.nvim'
Plug 'nvim-lua/plenary.nvim'
Plug 'nvim-telescope/telescope.nvim'
Plug 'styled-components/vim-styled-components', { 'branch': 'main' }
Plug 'jparise/vim-graphql'
Plug 'iamcco/markdown-preview.nvim', { 'do': 'cd app && yarn install'  }
" Bufferline
Plug 'akinsho/bufferline.nvim'
" Formatting
Plug 'mhartington/formatter.nvim'
"JSDoc
Plug 'heavenshell/vim-jsdoc', {
  \ 'for': ['javascript', 'javascript.jsx','typescript'],
  \ 'do': 'make install'
\}

call plug#end()
lua require("wesbragagt")

let g:rooter_patterns = ['.git', 'node_modules']
