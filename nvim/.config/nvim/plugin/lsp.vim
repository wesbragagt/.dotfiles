set completeopt=menu,menuone,noselect
lua << EOF
-- Setup nvim-cmp.
local cmp = require("cmp")

vim.lsp.handlers["textDocument/publishDiagnostics"] = vim.lsp.with(
    vim.lsp.diagnostic.on_publish_diagnostics, {
        virtual_text = true
    }
)

cmp.setup(
  {
    snippet = {
      expand = function(args)
        -- For `vsnip` user.
        vim.fn["vsnip#anonymous"](args.body)
      end
    },
    mapping = {
      ['<C-b>'] = cmp.mapping(cmp.mapping.scroll_docs(-4), { 'i', 'c' }),
      ['<C-f>'] = cmp.mapping(cmp.mapping.scroll_docs(4), { 'i', 'c' }),
      ['<C-Space>'] = cmp.mapping(cmp.mapping.complete(), { 'i', 'c' }),
      ['<C-y>'] = cmp.config.disable, -- Specify `cmp.config.disable` if you want to remove the default `<C-y>` mapping.
      ['<C-e>'] = cmp.mapping({
        i = cmp.mapping.abort(),
        c = cmp.mapping.close(),
      }),
      ['<CR>'] = cmp.mapping.confirm({ select = true }),    },
    sources = {
      {name = "nvim_lsp"},
      -- For vsnip user.
      {name = "vsnip"},
      {name = "buffer"}
    }
  }
)

-- Setup lspconfig.
-- Allows to pass custom configs to append to current default table
  local function config(_config)
    return vim.tbl_deep_extend("force", {
      capabilities = require("cmp_nvim_lsp").update_capabilities(vim.lsp.protocol.make_client_capabilities()),
    }, _config or {})
  end
  
  -- Attach to LSP client individually
  local lsp_installer_servers = require("nvim-lsp-installer.servers")
  local function setup_server(server, _config)
    local server_available, requested_server = lsp_installer_servers.get_server(server)
      if server_available then
          requested_server:on_ready(function ()
          requested_server:setup(_config)
          end)
      if not requested_server:is_installed() then
          requested_server:install()
      end
    end
  end
  -- cssls, stylelint_lsp, efm, sumneko_lua, diagnosticls, tsserver, tailwindcss, vimls
  setup_server("tsserver", config())
  setup_server("cssls", config())
  setup_server("tailwindcss", config())
  setup_server("vimls", config())
  setup_server("sumneko_lua", config({
  diagnostics = {
            -- Get the language server to recognize the `vim` global
            globals = {'vim'},
        },
  }))
  -- Todo: setup lua autocomplete for vim.api https://github.com/tjdevries/nlua.nvim
EOF

let mapleader = ' '
nnoremap <silent>gd <cmd>lua vim.lsp.buf.definition()<CR>
nnoremap <silent>gr <cmd>lua vim.lsp.buf.references()<CR>
nnoremap <silent>ca <cmd>lua vim.lsp.buf.code_action()<CR>
nnoremap <silent>K <cmd>lua vim.lsp.buf.hover()<CR>
nnoremap <leader>fo :Format<CR>
nnoremap <leader>lsp :LspInstallInfo<CR>
