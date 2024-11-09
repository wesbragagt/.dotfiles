return {
  {
    "onsails/lspkind.nvim"
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
      { "hrsh7th/nvim-cmp",                 event = 'InsertEnter' },
      { "hrsh7th/cmp-buffer" },
      { "hrsh7th/cmp-path" },
      { "saadparwaiz1/cmp_luasnip" },
      { "hrsh7th/cmp-nvim-lsp" },
      { "hrsh7th/cmp-nvim-lua" },
      { "lukas-reineke/cmp-rg" },

      -- Snippets
      { "L3MON4D3/LuaSnip" },
      { "rafamadriz/friendly-snippets" },
    },
  },
  { "windwp/nvim-ts-autotag", commit = "57035b5814f343bc6110676c9ae2eacfcd5340c2" },
  { "folke/lsp-colors.nvim" },
  { "folke/trouble.nvim" },
  { "folke/neodev.nvim" },
  {
    "pmizio/typescript-tools.nvim",
    dependencies = { "nvim-lua/plenary.nvim", "neovim/nvim-lspconfig" },
    build = "npm i -g @styled/typescript-styled-plugin typescript-styled-plugin"
  },
  {
    'ibhagwan/fzf-lua',
    -- optional for icon support
    dependencies = { 'nvim-tree/nvim-web-devicons', { 'junegunn/fzf', build = './install --bin', } },
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
  { "sindrets/diffview.nvim" },
  { "lewis6991/gitsigns.nvim" },
  { "f-person/git-blame.nvim" },
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
  { "mxsdev/nvim-dap-vscode-js",        commit = "b91e4e3634fe10f766960a8131bc9e42e47dddc9" },
  {
    "microsoft/vscode-js-debug",
    opt = true,
    build = "npm install && npm run compile",
    commit = "88b15b647d7827db05d4b9850d3e7a66eaba74cc",
  },
  { "rcarriga/nvim-dap-ui",           commit = "6b6081ad244ae5aa1358775cc3c08502b04368f9" },
  { "theHamsta/nvim-dap-virtual-text" },
  { "SSHari/jest.nvim" },
  { "stevearc/oil.nvim" },
  {
    "iamcco/markdown-preview.nvim",
    build = function()
      vim.fn["mkdp#util#install"]()
    end,
  },
  {
    "epwalsh/obsidian.nvim",
    tag = "v3.9.0", -- recommended, use latest release instead of latest commit
    dependencies = {
      "nvim-lua/plenary.nvim",
    },
  },
  { "windwp/nvim-autopairs", event = "InsertEnter" },
  { "nvim-pack/nvim-spectre" },
  {
    "github/copilot.vim"
  },
  {
    "CopilotC-Nvim/CopilotChat.nvim",
    tag = "v2.15.0",
    dependencies = {
      "nvim-lua/plenary.nvim",
    },
    build = "make tiktoken", -- Only on MacOS or Linux
  },
  { 'akinsho/bufferline.nvim', dependencies = 'nvim-tree/nvim-web-devicons', opts = {} }
}
