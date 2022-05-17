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
    autocmd BufWritePost plugins.lua source <afile>
  augroup end
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

return packer.startup(function(use)
	use("preservim/vimux")
	use("christoomey/vim-tmux-navigator")
	use("nathom/filetype.nvim")
	use("lewis6991/impatient.nvim")
	use({ "nvim-treesitter/nvim-treesitter", run = ":TSUpdate" })
	use("neovim/nvim-lspconfig")
	use("williamboman/nvim-lsp-installer")
	use("hrsh7th/cmp-nvim-lsp")
	use("hrsh7th/cmp-buffer")
	use("hrsh7th/cmp-path")
	use("hrsh7th/cmp-cmdline")
	use("hrsh7th/nvim-cmp")
	use("hrsh7th/cmp-nvim-lua")
	use("L3MON4D3/LuaSnip", {commit = "62faf9e"})
	use("saadparwaiz1/cmp_luasnip")
	use("folke/lua-dev.nvim")
	use("weilbith/nvim-code-action-menu")
	use("folke/trouble.nvim")
	use("folke/lsp-colors.nvim")
	use("jose-elias-alvarez/null-ls.nvim")
	use("rafamadriz/friendly-snippets")
	use("hrsh7th/cmp-vsnip")
	use("hrsh7th/vim-vsnip")
	use("akinsho/toggleterm.nvim")
	use("tpope/vim-fugitive")
	use("tpope/vim-rhubarb")
	use("f-person/git-blame.nvim")
	use("tpope/vim-commentary")
	use("nvim-lualine/lualine.nvim")
	use("lewis6991/gitsigns.nvim")
	use("preservim/nerdtree")
	use("ryanoasis/vim-devicons")
	use("lukas-reineke/indent-blankline.nvim")
	use("lunarvim/colorschemes")
	use({ "junegunn/fzf", run = "./bin/install.sh" })
	use("junegunn/fzf.vim")
	use("nvim-lua/popup.nvim")
	use("nvim-lua/plenary.nvim")
	use("sindrets/diffview.nvim")
	use("kyazdani42/nvim-web-devicons")
	use("akinsho/bufferline.nvim")
	-- Automatically set up your configuration after cloning packer.nvim
	-- Put this at the end after all plugins
	if PACKER_BOOTSTRAP then
		require("packer").sync()
	end
end)
