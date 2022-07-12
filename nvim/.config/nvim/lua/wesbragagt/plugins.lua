local fn = vim.fn

-- Automatically install packer
local install_path = fn.stdpath("data") .. "/site/pack/packer/start/packer.nvim"
if fn.empty(fn.glob(install_path)) > 0 then
	PACKER_BOOTSTRAP = fn.system({
		"git",
		"clone",
		"--depth",
		"1",
		"https://github.com/wbthomason/packer.nvim",
		install_path,
	})
	print("Installing packer close and reopen Neovim...")
	vim.cmd([[packadd packer.nvim]])
end

-- Autocommand that reloads neovim whenever you save the plugins.lua file
vim.cmd([[
  augroup packer_user_config
    autocmd!
    autocmd BufWritePost plugins.lua source <afile> | PackerSync
  augroup end
]])

vim.cmd([[ 
let g:gutentags_enabled = 0
let g:gitblame_enabled = 0
let g:rooter_manual_only=1
]])

-- Use a protected call so we don't error out on first use
local status_ok, packer = pcall(require, "packer")
if not status_ok then
	return
end

-- Have packer use a popup window
packer.init({
	display = {
		open_fn = function()
			return require("packer.util").float({ border = "rounded" })
		end,
	},
})

-- Install your plugins here
return packer.startup(function(use)
	-- My plugins here

	use({ "wbthomason/packer.nvim", commit = "00ec5adef58c5ff9a07f11f45903b9dbbaa1b422" }) -- Have packer manage itself

	use("windwp/nvim-ts-autotag")
	use("airblade/vim-rooter")
	use("jiangmiao/auto-pairs")
	use("L3MON4D3/LuaSnip")
	use("akinsho/bufferline.nvim")
	use("christoomey/vim-tmux-navigator")
	use("f-person/git-blame.nvim")
	use("folke/lsp-colors.nvim")
	use("folke/lua-dev.nvim")
	use("folke/trouble.nvim")
	use("hrsh7th/cmp-buffer")
	use("hrsh7th/cmp-cmdline")
	use("hrsh7th/cmp-nvim-lsp")
	use("hrsh7th/cmp-nvim-lua")
	use("hrsh7th/cmp-path")
	use("hrsh7th/cmp-vsnip")
	use("hrsh7th/nvim-cmp")
	use("hrsh7th/vim-vsnip")
	use("jose-elias-alvarez/null-ls.nvim")
	use("junegunn/fzf", { ["do"] = vim.fn["fzf#install"] })
	use("junegunn/fzf.vim")
	use("kyazdani42/nvim-web-devicons")
	use("lewis6991/gitsigns.nvim")
	use("lewis6991/impatient.nvim")
	use("lukas-reineke/indent-blankline.nvim")
	use("lunarvim/colorschemes")
	use("EdenEast/nightfox.nvim")
	use("nathom/filetype.nvim")
	use("neovim/nvim-lspconfig")
	use("nvim-lua/plenary.nvim")
	use("nvim-lua/popup.nvim")
	use("nvim-lualine/lualine.nvim")
	use("nvim-treesitter/nvim-treesitter", { run = ":TSUpdate" })
	use("preservim/nerdtree")
	use("preservim/vimux")
	use("rafamadriz/friendly-snippets")
	use("ryanoasis/vim-devicons")
	use("saadparwaiz1/cmp_luasnip")
	use("sindrets/diffview.nvim")
	use("tpope/vim-commentary")
	use("tpope/vim-fugitive")
	use("tpope/vim-rhubarb")
	use("weilbith/nvim-code-action-menu")
	use("williamboman/nvim-lsp-installer")

	-- Automatically set up your configuration after cloning packer.nvim
	-- Put this at the end after all plugins
	if PACKER_BOOTSTRAP then
		require("packer").sync()
	end
end)
