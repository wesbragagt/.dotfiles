local lsp_installer = require("nvim-lsp-installer")
-- Setup nvim-cmp.
local cmp = require "cmp"
local lspsaga = require "lspsaga"

cmp.setup(
  {
    snippet = {
      expand = function(args)
        -- For `vsnip` user.
        vim.fn["vsnip#anonymous"](args.body)
      end
    },
    mapping = {
      ["<C-d>"] = cmp.mapping.scroll_docs(-4),
      ["<C-f>"] = cmp.mapping.scroll_docs(4),
      ["<C-e>"] = cmp.mapping.close(),
      ["<CR>"] = cmp.mapping.confirm({select = true})
    },
    sources = {
      {name = "nvim_lsp"},
      -- For vsnip user.
      {name = "vsnip"},
      {name = "buffer"}
    }
  }
)

-- Setup lspconfig.
lsp_installer.on_server_ready(
  function(server)
    local opts = {}
    opts.capabilities = require("cmp_nvim_lsp").update_capabilities(vim.lsp.protocol.make_client_capabilities())
    if server.name == "stylelint_lsp" then
      opts.settings = {
        stylelintplus = {}
      }
    end
    server:setup(opts)
    vim.cmd [[ do User LspAttachBuffers ]]
  end
)
-- Lspsaga
lspsaga.init_lsp_saga()
