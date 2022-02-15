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
  {name = "DiagnosticSignError", text = ""},
  {name = "DiagnosticSignWarn", text = ""},
  {name = "DiagnosticSignHint", text = ""},
  {name = "DiagnosticSignInfo", text = ""}
}

for _, sign in ipairs(signs) do
  vim.fn.sign_define(sign.name, {texthl = sign.name, text = sign.text, numhl = ""})
end

vim.diagnostic.config {
  -- disable virtual text
  virtual_text = true,
  -- show signs
  signs = {
    active = signs
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
    prefix = ""
  }
}

vim.lsp.handlers["textDocument/hover"] =
  vim.lsp.with(
  vim.lsp.handlers.hover,
  {
    border = "rounded"
  }
)
vim.lsp.handlers["textDocument/signatureHelp"] =
  vim.lsp.with(
  vim.lsp.handlers.signature_help,
  {
    border = "rounded"
  }
)
require("luasnip.loaders.from_vscode").lazy_load()
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
  TypeParameter = ""
}
cmp.setup(
  {
    snippet = {
      expand = function(args)
        luasnip.lsp_expand(args.body)
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
    formatting = {
      fields = {"kind", "abbr", "menu"},
      format = function(entry, vim_item)
        -- Kind icons
        vim_item.kind = string.format("%s", kind_icons[vim_item.kind])
        -- vim_item.kind = string.format('%s %s', kind_icons[vim_item.kind], vim_item.kind) -- This concatonates the icons with the name of the item kind
        vim_item.menu =
          ({
          nvim_lsp = "[LSP]",
          luasnip = "[Snippet]",
          buffer = "[Buffer]",
          path = "[Path]"
        })[entry.source.name]
        return vim_item
      end
    },
    sources = {
      {name = "nvim_lsp"},
      {name = "luasnip"},
      {name = "buffer", keyword_length = 5},
      {name = "path"},
      {name = "nvim_lua"}
    },
    documentation = {
      border = {"╭", "─", "╮", "│", "╯", "─", "╰", "│"}
    },
    experimental = {
      ghost_text = false,
      native_menu = false
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

setup_server(
  "tsserver",
  config(
    {
      filetypes = {"typescript", "javascript", "javascriptreact", "typescriptreact"}
    }
  )
)
setup_server(
  "vuels",
  config(
    {
      cmd = {"vls"},
      filetypes = {"vue"},
      init_options = {
        config = {
          css = {},
          emmet = {},
          html = {
            suggest = {}
          },
          javascript = {
            format = {}
          },
          stylusSupremacy = {},
          typescript = {
            format = {}
          },
          vetur = {
            completion = {
              autoImport = true,
              tagCasing = "kebab",
              useScaffoldSnippets = false
            },
            format = {
              defaultFormatter = {
                js = "prettier",
                ts = "prettier"
              },
              defaultFormatterOptions = {},
              scriptInitialIndent = false,
              styleInitialIndent = false
            },
            useWorkspaceDependencies = true,
            validation = {
              script = true,
              style = true,
              template = true
            }
          }
        }
      }
    }
  )
)
setup_server("sumneko_lua", config(luadev))

local servers = {"cssls", "tailwindcss", "vimls", "yamlls", "ansiblels", "terraformls", "tflint"}
for _, lsp in ipairs(servers) do
  setup_server(lsp, config())
end
