local cmp_status_ok, cmp = pcall(require, "cmp")
if not cmp_status_ok then
	return
end

local snip_status_ok, luasnip = pcall(require, "luasnip")
if not snip_status_ok then
	return
end

require("luasnip/loaders/from_vscode").lazy_load()
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
	virtual_text = false,
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
--   פּ ﯟ   some other good icons
local kind_icons = {
	Text = "",
	Method = "m",
	Function = "",
	Constructor = "",
	Field = "",
	Variable = "",
	Class = "",
	Interface = "",
	Module = "",
	Property = "",
	Unit = "",
	Value = "",
	Enum = "",
	Keyword = "",
	Snippet = "",
	Color = "",
	File = "",
	Reference = "",
	Folder = "",
	EnumMember = "",
	Constant = "",
	Struct = "",
	Event = "",
	Operator = "",
	TypeParameter = "",
}
cmp.setup({
	snippet = {
		expand = function(args)
			luasnip.lsp_expand(args.body)
		end,
	},
	mapping = {
		["<C-b>"] = cmp.mapping(cmp.mapping.scroll_docs(-4), { "i", "c" }),
		["<C-f>"] = cmp.mapping(cmp.mapping.scroll_docs(4), { "i", "c" }),
		["<C-Space>"] = cmp.mapping(cmp.mapping.complete(), { "i", "c" }),
		["<C-e>"] = cmp.mapping.close(),
		["<Enter>"] = cmp.mapping.confirm({
			behavior = cmp.ConfirmBehavior.Insert,
			select = true,
		}),
		["<C-n>"] = cmp.mapping(function(fallback)
			if cmp.visible() then
				cmp.select_next_item()
			elseif luasnip.expand_or_jumpable() then
				luasnip.expand_or_jump()
			else
				fallback()
			end
		end, { "i", "s" }),
		["<C-p>"] = cmp.mapping(function(fallback)
			if cmp.visible() then
				cmp.select_prev_item()
			elseif luasnip.jumpable(-1) then
				luasnip.jump(-1)
			else
				fallback()
			end
		end, { "i", "s" }),
	},
	formatting = {
		fields = { "kind", "abbr", "menu" },
		format = function(entry, vim_item)
			-- Kind icons
			vim_item.kind = string.format("%s", kind_icons[vim_item.kind])
			-- vim_item.kind = string.format('%s %s', kind_icons[vim_item.kind], vim_item.kind) -- This concatonates the icons with the name of the item kind
			vim_item.menu = ({
				nvim_lsp = "[LSP]",
				buffer = "[Buffer]",
				path = "[Path]",
				luasnip = "[Snippet]",
			})[entry.source.name]
			return vim_item
		end,
	},
	sources = {
		{ name = "nvim_lsp" },
		{ name = "luasnip" },
		{ name = "buffer", keyword_length = 5 },
		{ name = "path" },
		{ name = "nvim_lua" },
	},
	experimental = {
		ghost_text = false,
		native_menu = false,
	},
})

-- Setup lspconfig.
-- Allows to pass custom configs to append to current default table
local function config(options)
	return vim.tbl_deep_extend("force", {
		capabilities = require("cmp_nvim_lsp").update_capabilities(vim.lsp.protocol.make_client_capabilities()),
		on_attach = function(client)
			-- use null-ls for this
			client.resolved_capabilities.document_formatting = false
			client.resolved_capabilities.document_range_formatting = false
		end,
	}, options or {})
end

-- Attach to LSP client individually
-- nvim_lua autocomplete https://github.com/folke/lua-dev.nvim
local luadev_status_ok,luadev = pcall(require, "lua-dev")
if not luadev_status_ok then
  return
end
luadev.setup({})

local function setup_server(server, _config)
	local lsp_installer_servers = require("nvim-lsp-installer.servers")
	local server_available, requested_server = lsp_installer_servers.get_server(server)
	if server_available then
		requested_server:on_ready(function()
			requested_server:setup(_config)
		end)
		if not requested_server:is_installed() then
			requested_server:install()
		end
	end
end
setup_server(
	"emmet_ls",
	config({
		filetypes = { "html", "css", "typescriptreact", "javascriptreact" },
	})
)
setup_server(
	"tsserver",
	config({
		filetypes = { "typescript", "javascript", "javascriptreact", "typescriptreact" },
		--root_dir = function(arg1, arg2) return vim.loop.cwd()end -- language server launch for any js files
		-- Needed for inlayHints. Merge this table with your settings or copy
		-- it from the source if you want to add your own init_options.
	})
)
setup_server(
	"vuels",
	config({
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
						tagCasing = "kebab",
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
						style = true,
						template = true,
					},
				},
			},
		},
	})
)
setup_server("sumneko_lua", config(luadev))
setup_server(
	"tailwindcss",
	config({
		filetypes = { "javascriptreact", "typescriptreact", "vue", "html", "css" },
	})
)
local servers = { "cssls", "vimls", "yamlls", "ansiblels", "jsonls", "terraformls", "tflint", "graphql" }
for _, lsp in ipairs(servers) do
	setup_server(lsp, config())
end
