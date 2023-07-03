local lsp = require("lsp-zero").preset({
  name = "recommended",
  sign_icons = {
    error = "",
    warn = "",
    hint = "",
    info = "",
  },
})

-- https://github.com/yioneko/nvim-vtsls
require("lspconfig").vtsls.setup({ --[[ your custom server config here ]] })

-- Neovim setup for init.lua and plugin development with full signature help, docs and completion for the nvim lua API.
-- https://github.com/folke/neodev.nvim
require("neodev").setup({})

lsp.ensure_installed(
  {
    "lua_ls",
    "volar",
    "vtsls",
    "tailwindcss",
    "cssls",
    "vimls",
    "yamlls",
    "ansiblels",
    "jsonls",
    "terraformls",
    "tflint",
    "eslint",
    "rust_analyzer",
    "emmet_ls",
    "pyright"
  }
)

lsp.configure('lua_ls', {
  settings = {
    Lua = {
      diagnostics = {
        globals = { "vim", "require" },
      },
    },
  },
})

function is_vue_project()
    local cwd = vim.fn.getcwd()
    local util = require("lspconfig.util")
    local project_root = util.find_node_modules_ancestor(cwd)

    local vue_path = util.path.join(project_root, "node_modules", "vue")
    local is_vue = vim.fn.isdirectory(vue_path) == 1

    return is_vue
end


 lsp.configure("vtsls", {
   capabilities = require("cmp_nvim_lsp").default_capabilities(vim.lsp.protocol.make_client_capabilities()),
   filetypes = { "typescript", "javascript", "javascriptreact", "typescriptreact" },
   root_dir = require("lspconfig").util.root_pattern("tsconfig.json", "jsconfig.json", "package.json"),
   init_options = require("nvim-lsp-ts-utils").init_options,
   on_attach = function(client, bufnr)
     local ts_utils = require("nvim-lsp-ts-utils")
     ts_utils.setup({
       auto_inlay_hints = false
     })
     -- required to fix code action ranges and filter diagnostics
     ts_utils.setup_client(client)

     -- no default maps, so you may want to define some here
     local opts = { silent = true }
     -- use null-ls for this
     client.server_capabilities.document_formatting = false
     client.server_capabilities.document_range_formatting = false
     vim.api.nvim_buf_set_keymap(bufnr, "n", "<Leader>es", ":EslintFixAll<CR>", { noremap = true })
     vim.api.nvim_buf_set_keymap(bufnr, "n", "gi", ":TSLspImportCurrent<CR>", opts)
   end,
 })

lsp.configure('volar', {
  filetypes = {
    "vue",
    "javascript",
    "javascript.jsx",
    "typescript",
    "typescript.tsx",
    "javascriptreact",
    "typescriptreact",
    "json",
  },
  on_attach = function()
    lsp.configure('vtsls', {
      autostart = false,
      root_dir = function()
        return false
      end,
      single_file_support = false,
    })
  end
})



local snip_status_ok, luasnip = pcall(require, "luasnip")
if not snip_status_ok then
  return
end

require("luasnip/loaders/from_vscode").lazy_load({
  path = { "snippets.lua" },
})

local cmp = require("cmp")
local cmp_select = { behavior = cmp.SelectBehavior.Select }
local cmp_mappings = lsp.defaults.cmp_mappings({
  ['<C-p>'] = cmp.mapping.select_prev_item(cmp_select),
  ['<C-n>'] = cmp.mapping.select_next_item(cmp_select),
  ['<C-y>'] = cmp.mapping.confirm({ select = true }),
  ["<C-Space>"] = cmp.mapping.complete(),
})

cmp_mappings['<Tab>'] = nil
cmp_mappings['<S-Tab>'] = nil

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

lsp.setup_nvim_cmp({
  mapping = cmp_mappings,
  formatting = {
    fields = { "kind", "abbr", "menu" },
    format = function(entry, vim_item)
      -- Kind icons
      vim_item.dup = { buffer = 1, path = 1, nvim_lsp = 0 }
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
    { name = "buffer",  keyword_length = 5 },
    { name = "path" },
    { name = "nvim_lua" },
    { name = "luasnip" },
  },
  experimental = {
    ghost_text = false,
    native_menu = false,
  },
})

local nnoremap = require("utils").nnoremap
lsp.on_attach(function(client, bufnr)
  local opts = { buffer = bufnr }

  -- Renaming references in buffer
  nnoremap("<leader>rb", vim.lsp.buf.rename, opts)
  nnoremap("gd", vim.lsp.buf.definition, opts)
  nnoremap("gr", vim.lsp.buf.references, opts)
  nnoremap("<leader>ca", ":CodeActionMenu<CR>", { buffer = bufnr, nowait = true })
  nnoremap("K", vim.lsp.buf.hover, opts)
  nnoremap("L", vim.diagnostic.open_float, opts)
  nnoremap("<leader>f", vim.lsp.buf.format, opts)
  nnoremap("<leader>ls", ":LspInfo<cr>", opts)
  nnoremap("<leader>lr", ":LspRestart<cr>", opts)

  if client.name == "eslint" then
    nnoremap("<leader>e", ":EslintFixAll<cr>")
  end

  if client.name == "tsserver" then
    nnoremap("<leader>fr", ":TSLspRenameFile<CR>")
  end
end)


lsp.setup()

vim.diagnostic.config({
  -- disable virtual text
  virtual_text = true,
  -- show signs
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
