return {
  {
    -- `lazydev` configures Lua LSP for your Neovim config, runtime and plugins
    -- used for completion, annotations and signatures of Neovim apis
    "folke/lazydev.nvim",
    ft = "lua",
    opts = {
      library = {
        -- Load luvit types when the `vim.uv` word is found
        { path = "${3rd}/luv/library", words = { "vim%.uv" } },
      },
    },
  },
  -- LSP STUFF
  { "williamboman/mason.nvim" },
  { "williamboman/mason-lspconfig.nvim" },
  {
    -- Main LSP Configuration
    "neovim/nvim-lspconfig",
    dependencies = {
      -- Automatically install LSPs and related tools to stdpath for Neovim
      -- Mason must be loaded before its dependents so we need to set it up here.
      -- NOTE: `opts = {}` is the same as calling `require('mason').setup({})`
      { "mason-org/mason.nvim", opts = {} },
      "mason-org/mason-lspconfig.nvim",
      "WhoIsSethDaniel/mason-tool-installer.nvim",

      -- Useful status updates for LSP.
      { "j-hui/fidget.nvim",    opts = {} },

      -- Allows extra capabilities provided by blink.cmp
      "saghen/blink.cmp",
    },
  },
  { -- Autocompletion
    "saghen/blink.cmp",
    event = "VimEnter",
    dependencies = {
      -- Snippet Engine
      {
        "L3MON4D3/LuaSnip",
        version = "2.*",
        build = (function()
          -- Build Step is needed for regex support in snippets.
          -- This step is not supported in many windows environments.
          -- Remove the below condition to re-enable on windows.
          if vim.fn.has("win32") == 1 or vim.fn.executable("make") == 0 then
            return
          end
          return "make install_jsregexp"
        end)(),
        dependencies = {
          -- `friendly-snippets` contains a variety of premade snippets.
          --    See the README about individual language/framework/plugin snippets:
          --    https://github.com/rafamadriz/friendly-snippets
          -- {
          --   'rafamadriz/friendly-snippets',
          --   config = function()
          --     require('luasnip.loaders.from_vscode').lazy_load()
          --   end,
          -- },
        },
      },
      "folke/lazydev.nvim",
    },
  },
  -- Use treesitter to autoclose and autorename html tag
  { "windwp/nvim-ts-autotag", commit = "57035b5814f343bc6110676c9ae2eacfcd5340c2" },
  { "folke/lsp-colors.nvim" },
  { "folke/trouble.nvim" },
  { "folke/neodev.nvim" },
  {
    "folke/snacks.nvim",
    priority = 1000,
    lazy = false,
    ---@type snacks.Config
    opts = {
      -- your configuration comes here
      -- or leave it empty to use the default settings
      -- refer to the configuration section below
      bigfile = { enabled = true },
      notifier = { enabled = true },
      quickfile = { enabled = true },
      statuscolumn = { enabled = true },
      words = { enabled = true },
    },
    keys = {
      { "<leader>ts", function() Snacks.scratch() end,        desc = "Toggle Scratch Buffer" },
      { "<leader>tf", function() Snacks.scratch.select() end, desc = "Select Scratch Buffer" },
    }
  },
  {
    "pmizio/typescript-tools.nvim",
    dependencies = { "nvim-lua/plenary.nvim", "neovim/nvim-lspconfig" },
    opts = {},
  },
  {
    "ibhagwan/fzf-lua",
    -- optional for icon support
    dependencies = { "nvim-tree/nvim-web-devicons" },
    commit = "b7bda51ba7d0c07aaa30e8428a6531e939f6c3a3",
  },
  { "nvim-lua/plenary.nvim" },
  {
    "nvim-telescope/telescope.nvim",
    tag = "0.1.2",
    dependencies = { { "nvim-lua/plenary.nvim" } },
  },
  -- ICONS
  { "nvim-tree/nvim-web-devicons" },
  { "ryanoasis/vim-devicons" },

  -- Git
  { "tpope/vim-fugitive" },
  {
    "sindrets/diffview.nvim",
    event = "VeryLazy",
  },
  {
    "f-person/git-blame.nvim",
    event = "VeryLazy",
    opts = { enabled = false },
  },
  { "lukas-reineke/indent-blankline.nvim" },

  -- COLORSCHEMES
  { "rebelot/kanagawa.nvim" },
  { "folke/tokyonight.nvim" },
  { "nvim-lua/popup.nvim" },
  {
    "nvim-lualine/lualine.nvim",
  },
  {
    "xiyaowong/transparent.nvim",
    config = function()
      vim.g.transparent_enabled = true
    end
  },
  -- Treesitter
  { "nvim-treesitter/nvim-treesitter", build = ":TSUpdate" },
  {
    "nvim-treesitter/nvim-treesitter-context",
    dependencies = {
      "nvim-treesitter/nvim-treesitter",
    },
  },
  {
    "nvim-treesitter/nvim-treesitter-textobjects",
    dependencies = {
      "nvim-treesitter/nvim-treesitter",
    },
  },
  -- Tmux
  { "christoomey/vim-tmux-navigator" },
  {
    "numToStr/Comment.nvim",
    config = function()
      require("Comment").setup()
    end,
  },
  { "tpope/vim-rhubarb" },
  -- DEBUGGER
  { "mfussenegger/nvim-dap" },
  { "mfussenegger/nvim-dap-python" },
  {
    "rcarriga/nvim-dap-ui",
    dependencies = { "mfussenegger/nvim-dap", "nvim-neotest/nvim-nio" },
    event = "VeryLazy",
  },
  { "theHamsta/nvim-dap-virtual-text" },
  -- File Manager vim editor
  { "stevearc/oil.nvim" },
  {
    "nvim-neo-tree/neo-tree.nvim",
    branch = "v3.x",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "MunifTanjim/nui.nvim",
      "nvim-tree/nvim-web-devicons",
    },
  },
  { "windwp/nvim-autopairs",          event = "InsertEnter" },
  -- Search and Replace
  { "nvim-pack/nvim-spectre",         event = "VeryLazy" },
  -- See file tab like icons on top
  { "akinsho/bufferline.nvim",        dependencies = "nvim-tree/nvim-web-devicons", opts = {} },
  {
    "akinsho/git-conflict.nvim",
    version = "*",
    config = true,
    event = "VeryLazy",
  },
}
