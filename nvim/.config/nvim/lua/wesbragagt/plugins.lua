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

	use({ "wbthomason/packer.nvim", commit = "00ec5adef58c5ff9a07f11f45903b9dbbaa1b422", lock = true }) -- Have packer manage itself
	use({ "windwp/nvim-ts-autotag", commit = "57035b5814f343bc6110676c9ae2eacfcd5340c2", lock = true })
	use({ "airblade/vim-rooter", lock = true })
	use({ "jiangmiao/auto-pairs", lock = true })
	use({ "L3MON4D3/LuaSnip", lock = true })
	use({ "christoomey/vim-tmux-navigator", lock = true })
	use({ "f-person/git-blame.nvim", lock = true })
	use({ "folke/lsp-colors.nvim", lock = true })
	use({ "folke/trouble.nvim", lock = true })
	use({ "hrsh7th/cmp-buffer", lock = true })
	use({ "hrsh7th/cmp-cmdline", lock = true })
	use({ "hrsh7th/cmp-nvim-lsp", lock = true })
	use({ "hrsh7th/cmp-nvim-lua", lock = true })
	use({ "hrsh7th/cmp-path", lock = true })
	use({ "hrsh7th/nvim-cmp", lock = true })
	use({ "jose-elias-alvarez/null-ls.nvim", lock = true })
	use({ "jose-elias-alvarez/nvim-lsp-ts-utils", lock = true })
	use({ "nvim-telescope/telescope.nvim", lock = true })
	use({ "nvim-telescope/telescope-fzf-native.nvim", run = "make", lock = true })
	use({ "nvim-lua/plenary.nvim", lock = true })
	use({ "kyazdani42/nvim-web-devicons", lock = true })
	use({ "lewis6991/gitsigns.nvim", lock = true })
	use({ "lewis6991/impatient.nvim", lock = true })
	use({ "lukas-reineke/indent-blankline.nvim", lock = true })
	use({ "EdenEast/nightfox.nvim", lock = true })
	use({ "folke/tokyonight.nvim", commit = "03c03eddace01bfe127f0a6d9413f84a960ea435" })
	use({ "catppuccin/nvim", lock = true })
	use({ "nathom/filetype.nvim", lock = true })
	use({ "neovim/nvim-lspconfig", lock = true })
	use({ "nvim-lua/popup.nvim", lock = true })
	use({ "nvim-lualine/lualine.nvim", lock = true })
	use({ "nvim-treesitter/nvim-treesitter", lock = true })
	use({ "nvim-treesitter/nvim-treesitter-context", lock = true })
	use({ "preservim/vimux", lock = true })
	use({ "rafamadriz/friendly-snippets", lock = true })
	use({ "ryanoasis/vim-devicons", lock = true })
	use({ "saadparwaiz1/cmp_luasnip", lock = true })
	use({ "sindrets/diffview.nvim", lock = true })
	use({ "tpope/vim-commentary", lock = true })
	use({ "tpope/vim-fugitive", lock = true })
	use({ "tpope/vim-rhubarb", lock = true })
	use({ "weilbith/nvim-code-action-menu", lock = true })
	use({ "williamboman/nvim-lsp-installer", lock = true })
	use({ "arjunmahishi/run-code.nvim", lock = true })
	use({ "mfussenegger/nvim-dap", lock = true })
	use({ "mxsdev/nvim-dap-vscode-js", lock = true })
	use({
		"microsoft/vscode-js-debug",
		opt = true,
		run = "yarn install && yarn compile",
		commit = "88b15b647d7827db05d4b9850d3e7a66eaba74cc",
		lock = true,
	})
	use({ "rcarriga/nvim-dap-ui", lock = true })
	use({ "theHamsta/nvim-dap-virtual-text", lock = true })
	use({ "gabrielpoca/replacer.nvim", lock = true })
	use({ "ThePrimeagen/harpoon", lock = true })
	use({ "SSHari/jest.nvim", lock = true })
	-- Automatically set up your configuration after cloning packer.nvim
	-- Put this at the end after all plugins
	if PACKER_BOOTSTRAP then
		require("packer").sync()
	end
end)
