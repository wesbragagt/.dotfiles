local is_lsp_zero_ok, lsp_zero = pcall(require, "lsp-zero")

if not is_lsp_zero_ok then
  return
end

local lsp = lsp_zero.preset({
  name = "recommended",
  sign_icons = {
    error = "",
    warn = "",
    hint = "",
    info = "",
  },
})

local is_neodev_ok, neodev = pcall(require, "neodev")
if is_neodev_ok then
  -- Neovim setup for init.lua and plugin development with full signature help, docs and completion for the nvim lua API.
  -- See: https://github.com/folke/neodev.nvim
  -- Als: https://github.com/rcarriga/nvim-dap-ui
  neodev.setup({
    library = { plugins = { "nvim-dap-ui", types = true } }
  })
end

lsp.ensure_installed(
  {
    "html",
    "lua_ls",
    "tailwindcss",
    "cssls",
    "vimls",
    "yamlls",
    "ansiblels",
    "jsonls",
    "emmet_ls",
    "pyright",
    "ts_ls",
    -- "eslint" -- buggy
  }
)

local lspconfig = require("lspconfig")
lsp.configure('lua_ls', {
  settings = {
    Lua = {
      diagnostics = {
        globals = { "vim", "require" },
      },
    },
  },
})

lsp.configure('eslint', {
  settings = {
    useFlatConfig = false,        -- set if using flat config
    experimental = {
      useFlatConfig = nil,       -- option not in the latest eslint-lsp
    },
  },
})

lsp.configure('pyright', {
  root_dir = lspconfig.util.root_pattern("pyproject.toml", "setup.py", "setup.cfg", "requirements.txt", "Pipfile"),
  settings = {
    python = {
      analysis = {
        typeCheckingMode = "basic",
        autoSearchPaths = true,
        useLibraryCodeForTypes = true,
      }
    }
  }
})

lsp.configure('tailwindcss', {
  settings = {
    filetypes = { "css", "less", "postcss", "sass", "scss", "stylus", "javascriptreact", "typescriptreact" }
  }
})

require("luasnip.loaders.from_vscode").lazy_load()

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

lsp.setup_nvim_cmp({
  mapping = cmp_mappings,
  formatting = {
    fields = { "kind", "abbr", "menu" },
    format = require("lspkind").cmp_format({
      mode = 'symbol', -- show only symbol annotations
      maxwidth = 50,   -- prevent the popup from showing more than provided characters (e.g 50 will not show more than 50 characters)
      -- can also be a function to dynamically calculate max width such as
      -- maxwidth = function() return math.floor(0.45 * vim.o.columns) end,
      ellipsis_char = '...',    -- when popup menu exceed maxwidth, the truncated part would show ellipsis_char instead (must define maxwidth first)
      show_labelDetails = true, -- show labelDetails in menu. Disabled by default

      -- The function below will be called before any actual modifications from lspkind
      -- so that you can provide more controls on popup customization. (See [#30](https://github.com/onsails/lspkind-nvim/pull/30))
      before = function(entry, vim_item)
        return vim_item
      end
    }),
  },
  sources = {
    { name = "nvim_lsp" },
    { name = "nvim_lua" },
    { name = "buffer",  keyword_length = 5 },
    {
      name = "rg",
      option = {
        keyword_length = 3,
        additional_arguments = "--hidden --smart-case"
      }
    },
    { name = "path" },
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
