local status_ok, null_ls = pcall(require, "null-ls")
if not status_ok then
	return
end

null_ls.setup({
	debug = true,
	sources = {
		null_ls.builtins.formatting.stylua,
		null_ls.builtins.diagnostics.eslint_d.with({
      prefer_local = "node_modules/.bin",
			condition = function(utils)
				return utils.root_has_file(".eslintrc")
			end,
		}),
		null_ls.builtins.formatting.prettierd,
		null_ls.builtins.code_actions.eslint_d,
		null_ls.builtins.hover.dictionary,
	},
	on_attach = function(client)
		-- if client.resolved_capabilities.document_formatting then
		-- 	vim.cmd([[
		-- augroup LspFormatting
		-- autocmd! * <buffer>
		-- autocmd BufWritePre <buffer> lua vim.lsp.buf.formatting_sync(nil, 2000)
		-- augroup END
		-- ]])
		-- end
	end,
})
