local lsp = require("lsp-zero")

local signs = {
	{ name = "DiagnosticSignError", text = "" },
	{ name = "DiagnosticSignWarn", text = "" },
	{ name = "DiagnosticSignHint", text = "" },
	{ name = "DiagnosticSignInfo", text = "" },
}

for _, sign in ipairs(signs) do
	vim.fn.sign_define(sign.name, { texthl = sign.name, text = sign.text, numhl = "" })
end

vim.diagnostic.config({
	-- disable virtual text
	virtual_text = true,
	-- show signs
	signs = {
		active = signs,
	},
	update_in_insert = true,
	underline = true,
	severity_sort = true,
	float = {
		focusable = false,
		style = "minimal",
		border = "rounded",
		source = "always",
		header = "",
		prefix = "",
	},
})

vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, {
	border = "rounded",
})
vim.lsp.handlers["textDocument/signatureHelp"] = vim.lsp.with(vim.lsp.handlers.signature_help, {
	border = "rounded",
})

lsp.preset("recommended")

lsp.ensure_installed({
	"tsserver",
	"eslint",
	"sumneko_lua",
	"cssls",
	"tailwindcss",
	"vuels",
	"vimls",
	"yamlls",
	"ansiblels",
	"jsonls",
	"terraformls",
	"tflint",
	"rust_analyzer",
	"emmet_ls",
})

lsp.configure("tsserver", {
	capabilities = require("cmp_nvim_lsp").default_capabilities(vim.lsp.protocol.make_client_capabilities()),
	filetypes = { "typescript", "javascript", "javascriptreact", "typescriptreact" },
	root_dir = require("lspconfig").util.root_pattern("tsconfig.json", "jsconfig.json", "package.json"),
	init_options = require("nvim-lsp-ts-utils").init_options,
	on_attach = function(client, bufnr)
		local ts_utils = require("nvim-lsp-ts-utils")

		-- defaults
		ts_utils.setup({
			debug = false,
			disable_commands = false,
			enable_import_on_completion = false,

			-- import all
			import_all_timeout = 5000, -- ms
			-- lower numbers = higher priority
			import_all_priorities = {
				same_file = 1, -- add to existing import statement
				local_files = 2, -- git files or files with relative path markers
				buffer_content = 3, -- loaded buffer content
				buffers = 4, -- loaded buffer names
			},
			import_all_scan_buffers = 100,
			import_all_select_source = false,
			-- if false will avoid organizing imports
			always_organize_imports = true,

			-- filter diagnostics
			filter_out_diagnostics_by_severity = {},
			filter_out_diagnostics_by_code = {},

			-- inlay hints
			auto_inlay_hints = false,
			inlay_hints_highlight = "Comment",
			inlay_hints_priority = 200, -- priority of the hint extmarks
			inlay_hints_throttle = 150, -- throttle the inlay hint request
			inlay_hints_format = { -- format options for individual hint kind
				Type = {},
				Parameter = {},
				Enum = {},
				-- Example format customization for `Type` kind:
				-- Type = {
				--     highlight = "Comment",
				--     text = function(text)
				--         return "->" .. text:sub(2)
				--     end,
				-- },
			},

			-- update imports on file move
			update_imports_on_move = false,
			require_confirmation_on_move = false,
			watch_dir = nil,
		})

		-- required to fix code action ranges and filter diagnostics
		ts_utils.setup_client(client)

		-- no default maps, so you may want to define some here
		local opts = { silent = true }
		-- use null-ls for this
		client.server_capabilities.document_formatting = false
		client.server_capabilities.document_range_formatting = false
		vim.api.nvim_buf_set_keymap(bufnr, "n", "<Leader>es", ":EslintFixAll<CR>", { noremap = true })
		vim.api.nvim_buf_set_keymap(bufnr, "n", "gi", ":TSLspImportCurrent<CR>", opts)
	end,
})

lsp.configure("vuels", {
	cmd = { "vls" },
	filetypes = { "vue" },
	init_options = {
		config = {
			css = {},
			emmet = {},
			html = {
				suggest = {},
			},
			javascript = {
				format = {},
			},
			stylusSupremacy = {},
			typescript = {
				format = {},
			},
			vetur = {
				completion = {
					autoImport = true,
					tagCasing = "PascalCase",
					useScaffoldSnippets = false,
				},
				format = {
					defaultFormatter = {
						js = "prettier",
						ts = "prettier",
					},
					defaultFormatterOptions = {},
					scriptInitialIndent = false,
					styleInitialIndent = false,
				},
				useWorkspaceDependencies = true,
				validation = {
					script = true,
					style = false,
					template = true,
				},
			},
		},
	},
})

lsp.configure("sumneko_lua", {
	settings = {
		Lua = {
			diagnostics = {
				-- Get the language server to recognize the `vim` global
				globals = { "vim" },
			},
			workspace = {
				library = vim.api.nvim_get_runtime_file("", true),
			},
		},
	},
})

lsp.configure("tailwindcss", {
	filetypes = { "typescriptreact", "vue", "html", "css" },
})

lsp.setup()
