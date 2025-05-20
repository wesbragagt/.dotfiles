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
			{ "j-hui/fidget.nvim", opts = {} },

			-- Allows extra capabilities provided by blink.cmp
			"saghen/blink.cmp",
		},
	},

	-- { -- Autoformat
	-- 	"stevearc/conform.nvim",
	-- 	event = { "BufWritePre" },
	-- 	cmd = { "ConformInfo" },
	-- 	keys = {
	-- 		{
	-- 			"<leader>f",
	-- 			function()
	-- 				require("conform").format({ async = true, lsp_format = "fallback" })
	-- 			end,
	-- 			mode = "",
	-- 			desc = "[F]ormat buffer",
	-- 		},
	-- 	},
	-- 	opts = {
	-- 		notify_on_error = false,
	-- 		format_on_save = function(bufnr)
	-- 			-- Disable "format_on_save lsp_fallback" for languages that don't
	-- 			-- have a well standardized coding style. You can add additional
	-- 			-- languages here or re-enable it for the disabled ones.
	-- 			local disable_filetypes = { c = true, cpp = true, kotlin = true }
	-- 			if disable_filetypes[vim.bo[bufnr].filetype] then
	-- 				return nil
	-- 			else
	-- 				return {
	-- 					timeout_ms = 500,
	-- 					lsp_format = "fallback",
	-- 				}
	-- 			end
	-- 		end,
	-- 		formatters_by_ft = {
	-- 			lua = { "stylua" },
	-- 			-- Conform can also run multiple formatters sequentially
	-- 			-- python = { "isort", "black" },
	-- 			--
	-- 			-- You can use 'stop_after_first' to run the first available formatter from the list
	-- 			-- javascript = { "prettierd", "prettier", stop_after_first = true },
	-- 		},
	-- 	},
	-- },

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
				opts = {},
			},
			"folke/lazydev.nvim",
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
		"karb94/neoscroll.nvim",
		opts = {
			mappings = { -- Keys to be mapped to their corresponding default scrolling animation
				"<C-u>",
				"<C-d>",
				"<C-b>",
				"<C-f>",
				"<C-y>",
				"<C-e>",
				"zt",
				"zz",
				"zb",
			},
			hide_cursor = true, -- Hide cursor while scrolling
			stop_eof = true, -- Stop at <EOF> when scrolling downwards
			respect_scrolloff = false, -- Stop scrolling when the cursor reaches the scrolloff margin of the file
			cursor_scrolls_alone = true, -- The cursor will keep on scrolling even if the window cannot scroll further
			duration_multiplier = 1.0, -- Global duration multiplier
			easing = "linear", -- Default easing function
			pre_hook = nil, -- Function to run before the scrolling animation starts
			post_hook = nil, -- Function to run after the scrolling animation ends
			performance_mode = false, -- Disable "Performance Mode" on all buffers.
			ignored_events = { -- Events ignored while scrolling
				"WinScrolled",
				"CursorMoved",
			},
		},
	},
	{
		"pmizio/typescript-tools.nvim",
		dependencies = { "nvim-lua/plenary.nvim", "neovim/nvim-lspconfig" },
		build = "npm i -g @styled/typescript-styled-plugin typescript-styled-plugin",
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
	-- { "lewis6991/gitsigns.nvim" },
	{
		"f-person/git-blame.nvim",
		event = "VeryLazy",
		opts = { enabled = false },
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
			"nvim-treesitter",
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
	{ "weilbith/nvim-code-action-menu" },
	{ "williamboman/mason.nvim" },
	{ "williamboman/mason-lspconfig.nvim" },
	{ "mfussenegger/nvim-dap" },
	{ "mfussenegger/nvim-dap-python" },
	-- {
	--   "microsoft/vscode-js-debug",
	--   build = "npm install --legacy-peer-deps && npx gulp vsDebugServerBundle && mv dist out",
	--   event = "VeryLazy"
	-- },
	{
		"rcarriga/nvim-dap-ui",
		dependencies = { "mfussenegger/nvim-dap", "nvim-neotest/nvim-nio" },
		event = "VeryLazy",
	},
	{ "theHamsta/nvim-dap-virtual-text" },
	{ "stevearc/oil.nvim" },
	{
		"iamcco/markdown-preview.nvim",
		build = function()
			vim.fn["mkdp#util#install"]()
		end,
	},
	{ "windwp/nvim-autopairs", event = "InsertEnter" },
	{ "nvim-pack/nvim-spectre", event = "VeryLazy" },
	{
		"github/copilot.vim",
	},
	{ "akinsho/bufferline.nvim", dependencies = "nvim-tree/nvim-web-devicons", opts = {} },
	{
		"akinsho/git-conflict.nvim",
		version = "*",
		config = true,
		event = "VeryLazy",
	},
}
