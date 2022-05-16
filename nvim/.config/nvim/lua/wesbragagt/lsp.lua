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
local luadev = require("lua-dev").setup({})

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
local util = require("lspconfig.util")
setup_server(
	"tsserver",
	config({
		filetypes = { "typescript", "javascript", "javascriptreact", "typescriptreact" },
    root_dir = util.root_pattern("jsconfig.json", "tsconfig.json", "node_modules")
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
local servers = { "cssls", "vimls", "yamlls", "ansiblels", "jsonls", "terraformls", "tflint", "eslint" }
for _, lsp in ipairs(servers) do
	setup_server(lsp, config())
end

vim.cmd([[
let mapleader = ' '
" LSP
nnoremap <silent>gd <cmd>lua vim.lsp.buf.definition()<CR>
nnoremap <silent>gr <cmd>lua vim.lsp.buf.references()<CR>
" nnoremap <silent>ca <cmd>lua vim.lsp.buf.code_action()<CR>
nnoremap <silent>ca :CodeActionMenu<CR>
nnoremap <silent>K <cmd>lua vim.lsp.buf.hover()<CR>
nnoremap <silent>L <cmd>lua vim.diagnostic.open_float()<CR>
nnoremap <leader>fo <cmd>lua vim.lsp.buf.formatting_sync(nil, 2000)<CR>
]])
