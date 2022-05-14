if (has("termguicolors"))
  set termguicolors
endif

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
" Code Action Menu
Plug 'weilbith/nvim-code-action-menu'
" Diagnostics
Plug 'folke/trouble.nvim'
Plug 'folke/lsp-colors.nvim'
Plug 'jose-elias-alvarez/null-ls.nvim'
" For vsnip user.
Plug 'rafamadriz/friendly-snippets'
Plug 'hrsh7th/cmp-vsnip'
Plug 'hrsh7th/vim-vsnip'
Plug 'akinsho/toggleterm.nvim'
" Git
Plug 'tpope/vim-fugitive'
Plug 'tpope/vim-rhubarb'
Plug 'f-person/git-blame.nvim'
" Comments
Plug 'tpope/vim-commentary'
" Status
Plug 'nvim-lualine/lualine.nvim'
Plug 'lewis6991/gitsigns.nvim'
Plug 'preservim/nerdtree'
Plug 'ryanoasis/vim-devicons'

" Indentline
Plug 'lukas-reineke/indent-blankline.nvim'

" Colorscheme
Plug 'lunarvim/colorschemes'
Plug 'lifepillar/vim-gruvbox8'

Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'

Plug 'jiangmiao/auto-pairs' "this will auto close ( [ {
Plug 'nvim-lua/popup.nvim'
Plug 'nvim-lua/plenary.nvim'
Plug 'sindrets/diffview.nvim'
" Bufferline
Plug 'kyazdani42/nvim-web-devicons' " Recommended (for coloured icons)
" Plug 'ryanoasis/vim-devicons' Icons without colours
Plug 'akinsho/bufferline.nvim'
" @deprecated Formatting
" Plug 'mhartington/formatter.nvim'
call plug#end()
let g:rooter_patterns = ['.git', 'node_modules']
" To toggle between automatic and manual behaviour, use :RooterToggle. or
" <leader>/
let g:rooter_manual_only = 1
" Git Blame
let g:gitblame_enabled = 0
lua require("wesbragagt")
