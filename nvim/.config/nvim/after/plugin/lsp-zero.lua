local lsp = require("lsp-zero").preset({
  name = "recommended",
  sign_icons = {
    error = "",
    warn = "",
    hint = "",
    info = "",
  },
})

local function install_servers()
  local my_servers = {
    "lua_ls",
    "tsserver",
    "volar",
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
  }
  lsp.ensure_installed(my_servers)
end

local function setup_server(server, _config)
  lsp.configure(server, _config)
end

install_servers()

setup_server('lua-language-server', {
  settings = {
    Lua = {
      diagnostics = {
        globals = { "vim", "require" },
      },
    },
  },
})


setup_server("tsserver", {
  capabilities = require("cmp_nvim_lsp").default_capabilities(vim.lsp.protocol.make_client_capabilities()),
  filetypes = { "typescript", "javascript", "javascriptreact", "typescriptreact" },
  root_dir = require("lspconfig").util.root_pattern("tsconfig.json", "jsconfig.json", "package.json"),
  init_options = require("nvim-lsp-ts-utils").init_options,
  on_attach = function(client, bufnr)
    local ts_utils = require("nvim-lsp-ts-utils")

    -- defaults
    ts_utils.setup({
      debug = false,
      disable_commands = false,
      enable_import_on_completion = false,
      -- import all
      import_all_timeout = 5000, -- ms
      -- lower numbers = higher priority
      import_all_priorities = {
        same_file = 1, -- add to existing import statement
        local_files = 2, -- git files or files with relative path markers
        buffer_content = 3, -- loaded buffer content
        buffers = 4, -- loaded buffer names
      },
      import_all_scan_buffers = 100,
      import_all_select_source = false,
      -- if false will avoid organizing imports
      always_organize_imports = true,
      -- filter diagnostics
      filter_out_diagnostics_by_severity = {},
      filter_out_diagnostics_by_code = {},
      -- inlay hints
      auto_inlay_hints = false,
      inlay_hints_highlight = "Comment",
      inlay_hints_priority = 200, -- priority of the hint extmarks
      inlay_hints_throttle = 150, -- throttle the inlay hint request
      inlay_hints_format = { -- format options for individual hint kind
        Type = {},
        Parameter = {},
        Enum = {},
      },
      -- update imports on file move
      update_imports_on_move = false,
      require_confirmation_on_move = false,
      watch_dir = nil,
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


local snip_status_ok, luasnip = pcall(require, "luasnip")
if not snip_status_ok then
  return
end
require("luasnip/loaders/from_vscode").lazy_load({
  path = { "snippets.lua" },
})
local cmp = require("cmp")
local cmp_mappings = lsp.defaults.cmp_mappings({
  ["<C-b>"] = cmp.mapping(cmp.mapping.scroll_docs(-4), { "i", "c" }),
  ["<C-f>"] = cmp.mapping(cmp.mapping.scroll_docs(4), { "i", "c" }),
  ["<C-Space>"] = cmp.mapping(cmp.mapping.complete({}), { "i", "c" }),
  ["<C-e>"] = cmp.mapping.close(),
  ["<Enter>"] = cmp.mapping.confirm({
    behavior = cmp.ConfirmBehavior.Insert,
    select = true,
  }),
  ["<C-n>"] = cmp.mapping(function(fallback)
    if cmp.visible() then
      cmp.select_next_item()
    elseif luasnip.expand_or_jumpable() then
      luasnip.expand_or_jump()
    else
      fallback()
    end
  end, { "i", "s" }),
  ["<C-p>"] = cmp.mapping(function(fallback)
    if cmp.visible() then
      cmp.select_prev_item()
    elseif luasnip.jumpable(-1) then
      luasnip.jump(-1)
    else
      fallback()
    end
  end, { "i", "s" }),
})

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
    { name = "buffer", keyword_length = 5 },
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
  nnoremap("ca", ":CodeActionMenu<CR>", opts)
  nnoremap("K", vim.lsp.buf.hover, opts)
  nnoremap("L", vim.diagnostic.open_float, opts)
  nnoremap("<leader>f", vim.lsp.buf.format, opts)
  nnoremap("<leader>ls", ":LspInfo<cr>", opts)

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
