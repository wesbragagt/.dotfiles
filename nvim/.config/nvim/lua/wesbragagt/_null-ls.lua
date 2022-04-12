local status_ok, null_ls = pcall(require, "null-ls")
if not status_ok then
  return
end

  null_ls.setup(
    {
      debug = true,
      sources = {
        null_ls.builtins.formatting.stylua,
        null_ls.builtins.diagnostics.eslint,
        null_ls.builtins.formatting.prettierd
      },
      on_attach = function(client)
          if client.resolved_capabilities.document_formatting then
              vim.cmd([[
              augroup LspFormatting
                  autocmd! * <buffer>
                  autocmd BufWritePre <buffer> lua vim.lsp.buf.formatting_sync()
              augroup END
              ]])
          end
      end,
    }
  )

vim.cmd[[
nnoremap <silent>lua vim.lsp.buf.formatting_sync()<CR>
]]
