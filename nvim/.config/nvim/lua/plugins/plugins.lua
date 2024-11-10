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
	{ "windwp/nvim-autopairs",  event = "InsertEnter" },
	{ "nvim-pack/nvim-spectre", event = "VeryLazy" },
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
	{ 'akinsho/bufferline.nvim', dependencies = 'nvim-tree/nvim-web-devicons', opts = {} },
	{
		'akinsho/git-conflict.nvim',
		version = "*",
		config = true,
		event = "VeryLazy"
	},
	{
		"folke/noice.nvim",
		event = "VeryLazy",
		opts = {
			cmdline = {
				view = "cmdline",
			},
			lsp = {
				-- override markdown rendering so that **cmp** and other plugins use **Treesitter**
				override = {
					["vim.lsp.util.convert_input_to_markdown_lines"] = true,
					["vim.lsp.util.stylize_markdown"] = true,
					["cmp.entry.get_documentation"] = true, -- requires hrsh7th/nvim-cmp
				},
			},
			-- you can enable a preset for easier configuration
			presets = {
				bottom_search = true, -- use a classic bottom cmdline for search
				command_palette = true, -- position the cmdline and popupmenu together
				long_message_to_split = true, -- long messages will be sent to a split
				inc_rename = false, -- enables an input dialog for inc-rename.nvim
				lsp_doc_border = false, -- add a border to hover docs and signature help
			},
		},
		dependencies = {
			-- if you lazy-load any plugin below, make sure to add proper `module="..."` entries
			"MunifTanjim/nui.nvim",
			-- OPTIONAL:
			--   `nvim-notify` is only needed, if you want to use the notification view.
			--   If not available, we use `mini` as the fallback
			"rcarriga/nvim-notify",
		}
	}
}
