set completeopt=menuone,noselect

lua << EOF
local lsp = require('lspconfig')
-- Setup nvim-cmp.
local cmp = require'cmp'
local lspsaga = require'lspsaga'

  cmp.setup({
    snippet = {
      expand = function(args)
        -- For `vsnip` user.
        vim.fn["vsnip#anonymous"](args.body)
      end,
    },
    mapping = {
      ['<C-d>'] = cmp.mapping.scroll_docs(-4),
      ['<C-f>'] = cmp.mapping.scroll_docs(4),
      ['<C-e>'] = cmp.mapping.close(),
      ['<CR>'] = cmp.mapping.confirm({ select = true }),
    },
    sources = {
      { name = 'nvim_lsp' },

      -- For vsnip user.
      { name = 'vsnip' },

      { name = 'buffer' },
    }
  })

  -- Setup lspconfig.
  lsp.tsserver.setup {
    capabilities = require('cmp_nvim_lsp').update_capabilities(vim.lsp.protocol.make_client_capabilities())
  }
-- Lspsaga
lspsaga.init_lsp_saga()
EOF

let mapleader = ' '
nnoremap <silent><leader>ca :Lspsaga code_action<CR>
nnoremap <silent>K :Lspsaga hover_doc<CR>
