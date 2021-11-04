lua << EOF
local lsp = require("lspconfig")
-- Setup nvim-cmp.
local cmp = require("cmp")
local lspsaga = require("lspsaga")

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
local lsp_installer = require("nvim-lsp-installer")

lsp_installer.on_server_ready(function(server)
    local opts = {}
    opts.capabilities = require("cmp_nvim_lsp").update_capabilities(vim.lsp.protocol.make_client_capabilities())
    -- (optional) Customize the options passed to the server
    -- if server.name == "tsserver" then
    --     opts.root_dir = function() ... end
    -- end

    -- This setup() function is exactly the same as lspconfig's setup function (:help lspconfig-quickstart)
    server:setup(opts)
    vim.cmd [[ do User LspAttachBuffers ]]
end)
-- Lspsaga
lspsaga.init_lsp_saga()
EOF

let mapleader = ' '
nnoremap <silent>gd <cmd>lua vim.lsp.buf.definition()<CR>
nnoremap <silent>gr <cmd>lua vim.lsp.buf.references()<CR>
nnoremap <silent><leader>ca :Lspsaga code_action<CR>
nnoremap <silent>K :Lspsaga hover_doc<CR>
nnoremap <leader>fo :Format<CR>
nnoremap <leader>lsp :LspInstallInfo<CR>

