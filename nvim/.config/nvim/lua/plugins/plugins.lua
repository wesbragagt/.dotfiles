return {
  {
    "onsails/lspkind.nvim",
    event = "BufRead"
  },
  {
    "VonHeikemen/lsp-zero.nvim",
    branch = "v1.x",
    dependencies = {
      -- LSP Support
      { "neovim/nvim-lspconfig", },
      { "williamboman/mason.nvim" },
      { "williamboman/mason-lspconfig.nvim" },

      -- Autocompletion
      {
        "hrsh7th/nvim-cmp",
        event = 'InsertEnter'
      },
      {
        "hrsh7th/cmp-buffer",
        event = 'InsertEnter'
      },
      {
        "hrsh7th/cmp-path",
        event = "InsertEnter"
      },
      {
        "saadparwaiz1/cmp_luasnip",
        event = "InsertEnter"
      },
      {
        "hrsh7th/cmp-nvim-lsp",
        event = "InsertEnter"
      },
      {
        "hrsh7th/cmp-nvim-lua",
        event = "InsertEnter"
      },
      {
        "lukas-reineke/cmp-rg",
        event = "InsertEnter"
      },

      -- Snippets
      {
        "L3MON4D3/LuaSnip",
        event = "InsertEnter"
      },
      {
        "rafamadriz/friendly-snippets",
        event = "InsertEnter"
      },
    },
  },
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
  },
  {
    "pmizio/typescript-tools.nvim",
    dependencies = { "nvim-lua/plenary.nvim", "neovim/nvim-lspconfig" },
    build = "npm i -g @styled/typescript-styled-plugin typescript-styled-plugin"
  },
  {
    'ibhagwan/fzf-lua',
    -- optional for icon support
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    commit = "b7bda51ba7d0c07aaa30e8428a6531e939f6c3a3"
  },
  { "nvim-lua/plenary.nvim" },
  {
    'nvim-telescope/telescope.nvim',
    tag = '0.1.2',
    dependencies = { { 'nvim-lua/plenary.nvim' } }
  },
  -- ICONS
  { "nvim-tree/nvim-web-devicons" },
  { "ryanoasis/vim-devicons" },

  -- Git
  { "tpope/vim-fugitive" },
  {
    "sindrets/diffview.nvim",
    event = "VeryLazy"
  },
  { "lewis6991/gitsigns.nvim" },
  {
    "f-person/git-blame.nvim",
    event = "VeryLazy",
    opts = { enabled = false }
  },
  { "lukas-reineke/indent-blankline.nvim" },

  -- COLORSCHEMES
  { "rebelot/kanagawa.nvim" },
  { "nvim-lua/popup.nvim" },
  {
    "nvim-lualine/lualine.nvim",
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
  {
    "tadmccorkle/markdown.nvim",
    dependencies = {
      "nvim-treesitter"
    }
  },

  -- Tmux
  { "christoomey/vim-tmux-navigator" },
  {
    'numToStr/Comment.nvim',
    config = function()
      require('Comment').setup()
    end
  },
  { "tpope/vim-rhubarb" },
  { "weilbith/nvim-code-action-menu" },
  { "williamboman/mason.nvim" },
  { "williamboman/mason-lspconfig.nvim" },
  { "mfussenegger/nvim-dap" },
  { "mfussenegger/nvim-dap-python" },
  {
    "microsoft/vscode-js-debug",
    build = "npm install --legacy-peer-deps && npx gulp vsDebugServerBundle && mv dist out",
    event = "VeryLazy"
  },
  { "rcarriga/nvim-dap-ui",
    dependencies = { "mfussenegger/nvim-dap", "nvim-neotest/nvim-nio" },
    event = "VeryLazy"
  },
  { "theHamsta/nvim-dap-virtual-text" },
  { "stevearc/oil.nvim" },
  {
    "iamcco/markdown-preview.nvim",
    build = function()
      vim.fn["mkdp#util#install"]()
    end,
  },
  { "windwp/nvim-autopairs",  event = "InsertEnter" },
  { "nvim-pack/nvim-spectre", event = "VeryLazy" },
  {
    "github/copilot.vim"
  },
  { 'akinsho/bufferline.nvim', dependencies = 'nvim-tree/nvim-web-devicons', opts = {} },
  {
    'akinsho/git-conflict.nvim',
    version = "*",
    config = true,
    event = "VeryLazy"
  }
}
