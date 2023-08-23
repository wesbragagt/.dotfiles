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
  use({
    "VonHeikemen/lsp-zero.nvim",
    branch = "v1.x",
    requires = {
      -- LSP Support
      { "neovim/nvim-lspconfig" },
      { "williamboman/mason.nvim" },
      { "williamboman/mason-lspconfig.nvim" },

      -- Autocompletion
      { "hrsh7th/nvim-cmp" },
      { "hrsh7th/cmp-buffer" },
      { "hrsh7th/cmp-path" },
      { "saadparwaiz1/cmp_luasnip" },
      { "hrsh7th/cmp-nvim-lsp" },
      { "hrsh7th/cmp-nvim-lua" },

      -- Snippets
      { "L3MON4D3/LuaSnip" },
      { "rafamadriz/friendly-snippets" },
    },
  })
  use({ "windwp/nvim-ts-autotag", commit = "57035b5814f343bc6110676c9ae2eacfcd5340c2" })
  use({ "folke/lsp-colors.nvim" })
  use({ "folke/trouble.nvim" })
  use({ "folke/neodev.nvim" })
  use({
    "pmizio/typescript-tools.nvim",
    requires = { "nvim-lua/plenary.nvim", "neovim/nvim-lspconfig" },
  })

  use({ "nvim-telescope/telescope.nvim" })
  use({ "nvim-telescope/telescope-fzf-native.nvim", run = "make" })
  use { 'ibhagwan/fzf-lua',
    -- optional for icon support
    requires = { 'nvim-tree/nvim-web-devicons', { 'junegunn/fzf', run = './install --bin', } },
    commit = "b7bda51ba7d0c07aaa30e8428a6531e939f6c3a3"
  }
  use({ "nvim-lua/plenary.nvim" })
  -- ICONS
  use({ "nvim-tree/nvim-web-devicons" })
  use({ "ryanoasis/vim-devicons", opt = true })

  -- Git
  use({ "tpope/vim-fugitive" })
  use({ "sindrets/diffview.nvim" })
  use({ "lewis6991/gitsigns.nvim" })
  use({ "f-person/git-blame.nvim" })
  use({ "lukas-reineke/indent-blankline.nvim" })

  -- COLORSCHEMES
  use({ "EdenEast/nightfox.nvim" })
  use({ "catppuccin/nvim" })
  use { "rebelot/kanagawa.nvim" }

  use({ "nvim-lua/popup.nvim" })
  use({
    "nvim-lualine/lualine.nvim",
  })
  -- Treesitter
  use({ "nvim-treesitter/nvim-treesitter" })
  use({ "nvim-treesitter/nvim-treesitter-context" })

  -- Tmux
  use({ "christoomey/vim-tmux-navigator" })
  use({ "tpope/vim-commentary" })
  use({ "tpope/vim-rhubarb" })
  use({ "weilbith/nvim-code-action-menu" })
  use({ "williamboman/mason.nvim" })
  use({ "williamboman/mason-lspconfig.nvim" })
  use({ "mfussenegger/nvim-dap" })
  use({ "mxsdev/nvim-dap-vscode-js" })
  use({
    "microsoft/vscode-js-debug",
    opt = true,
    run = "yarn install && yarn compile",
    commit = "88b15b647d7827db05d4b9850d3e7a66eaba74cc",
  })
  use({ "rcarriga/nvim-dap-ui", commit = "6b6081ad244ae5aa1358775cc3c08502b04368f9" })
  use({ "theHamsta/nvim-dap-virtual-text" })
  use({ "ThePrimeagen/harpoon" })
  use({ "SSHari/jest.nvim" })
  use({ "stevearc/oil.nvim" })
  use({
    "iamcco/markdown-preview.nvim",
    run = function()
      vim.fn["mkdp#util#install"]()
    end,
  })
  use({ "nvim-pack/nvim-spectre" })
  use({ "ThePrimeagen/vim-be-good" })
  use({ "yioneko/nvim-vtsls" })
  use({ "windwp/nvim-autopairs" })
  use({ "github/copilot.vim" })
  -- Automatically set up your configuration after cloning packer.nvim
  -- Put this at the end after all plugins
  if PACKER_BOOTSTRAP then
    require("packer").sync()
  end
end)
