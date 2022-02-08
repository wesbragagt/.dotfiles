local status_ok, cmp = pcall(require, "cmp")
if not status_ok then
  return
end
vim.diagnostic.config {
  virtual_text = {
    prefix = ""
  },
  signs = true,
  underline = true,
  update_in_insert = false
}

vim.lsp.handlers["textDocument/hover"] =
  vim.lsp.with(
  vim.lsp.handlers.hover,
  {
    border = "single"
  }
)
vim.lsp.handlers["textDocument/signatureHelp"] =
  vim.lsp.with(
  vim.lsp.handlers.signature_help,
  {
    border = "single"
  }
)
--vim.lsp.handlers["textDocument/publishDiagnostics"] =
--  vim.lsp.with(
--  vim.lsp.diagnostic.on_publish_diagnostics,
--  {
--    virtual_text = true
--  }
--)
require("luasnip.loaders.from_vscode").lazy_load()
cmp.setup(
  {
    snippet = {
      expand = function(args)
        require("luasnip").lsp_expand(args.body)
      end
    },
    mapping = {
      ["<C-b>"] = cmp.mapping(cmp.mapping.scroll_docs(-4), {"i", "c"}),
      ["<C-f>"] = cmp.mapping(cmp.mapping.scroll_docs(4), {"i", "c"}),
      ["<C-Space>"] = cmp.mapping(cmp.mapping.complete(), {"i", "c"}),
      ["<C-e>"] = cmp.mapping.close(),
      ["<C-y>"] = cmp.mapping.confirm(
        {
          behavior = cmp.ConfirmBehavior.Insert,
          select = true
        }
      )
    },
    sources = {
      {name = "nvim_lsp"},
      {name = "path"},
      {name = "luasnip"},
      {name = "buffer", keyword_length = 5},
      {name = "nvim_lua"}
    }
  }
)

-- Setup lspconfig.
-- Allows to pass custom configs to append to current default table
local function config(_config)
  return vim.tbl_deep_extend(
    "force",
    {
      capabilities = require("cmp_nvim_lsp").update_capabilities(vim.lsp.protocol.make_client_capabilities())
    },
    _config or {}
  )
end

-- Attach to LSP client individually
-- nvim_lua autocomplete https://github.com/folke/lua-dev.nvim
local luadev = require("lua-dev").setup({})

local function setup_server(server, _config)
  local lsp_installer_servers = require("nvim-lsp-installer.servers")
  local server_available, requested_server = lsp_installer_servers.get_server(server)
  if server_available then
    requested_server:on_ready(
      function()
        requested_server:setup(_config)
      end
    )
    if not requested_server:is_installed() then
      requested_server:install()
    end
  end
end

local servers = {"tsserver", "vuels", "cssls", "tailwindcss", "vimls", "yamlls", "ansiblels", "terraformls", "tflint"}

for _, lsp in ipairs(servers) do
  setup_server(lsp, config())
end
setup_server("sumneko_lua", config(luadev))
