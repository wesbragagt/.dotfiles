local fn = vim.fn
local install_path = fn.stdpath("data") .. "/site/pack/packer/start/packer.nvim"
if fn.empty(fn.glob(install_path)) > 0 then
	packer_bootstrap = fn.system({
		"git",
		"clone",
		"--depth",
		"1",
		"https://github.com/wbthomason/packer.nvim",
		install_path,
	})
end

return require("packer").startup(function(use)
	use("preservim/vimux")
	use("christoomey/vim-tmux-navigator")
	use("airblade/vim-rooter")
	-- Boost startup
	use("nathom/filetype.nvim")
	use("lewis6991/impatient.nvim")
	-- Treesitter
	use("nvim-treesitter/nvim-treesitter", { run = ":TSUpdate" })
	-- LSP
	use("neovim/nvim-lspconfig")
	use("williamboman/nvim-lsp-installer")
	use("hrsh7th/cmp-nvim-lsp")
	use("hrsh7th/cmp-buffer")
	use("hrsh7th/cmp-path")
	use("hrsh7th/cmp-cmdline")
	use("hrsh7th/nvim-cmp")
	use("hrsh7th/cmp-nvim-lua")
	use("L3MON4D3/LuaSnip")
	use("saadparwaiz1/cmp_luasnip")
	use("folke/lua-dev.nvim")
	-- Code Action Menu
	use("weilbith/nvim-code-action-menu")
	-- Diagnostics
	use("folke/trouble.nvim")
	use("folke/lsp-colors.nvim")
	use("jose-elias-alvarez/null-ls.nvim")
	--For vsnip user.
	use("rafamadriz/friendly-snippets")
	use("hrsh7th/cmp-vsnip")
	use("hrsh7th/vim-vsnip")
	use("akinsho/toggleterm.nvim")
	-- Git
	use("tpope/vim-fugitive")
	use("tpope/vim-rhubarb")
	use("f-person/git-blame.nvim")
	-- Comments
	use("tpope/vim-commentary")
	-- Status
	use("nvim-lualine/lualine.nvim")
	use("lewis6991/gitsigns.nvim")
	use("preservim/nerdtree")
	use("ryanoasis/vim-devicons")

	-- Indentline
	use("lukas-reineke/indent-blankline.nvim")

	-- Colorscheme
	use("lunarvim/colorschemes")
	use("lifepillar/vim-gruvbox8")

	use("junegunn/fzf", { run = "./install --bin" })
	use("junegunn/fzf.vim")
	-- this will auto close ( [ {
	use("jiangmiao/auto-pairs")
	use("nvim-lua/popup.nvim")
	use("nvim-lua/plenary.nvim")
	use("sindrets/diffview.nvim")
	--Bufferline
	use("kyazdani42/nvim-web-devicons")
	use("akinsho/bufferline.nvim")

	-- Automatically set up your configuration after cloning packer.nvim
	-- Put this at the end after all plugins
	if packer_bootstrap then
		require("packer").sync()
	end
end)
