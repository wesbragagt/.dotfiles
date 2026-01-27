local utils = {}

local function extend_options(opts)
  local options = {}
  if opts then
    options = vim.tbl_extend("force", options, opts)
  end
  return options
end

function utils.nnoremap(keymap, command, opts)
  vim.keymap.set("n", keymap, command, extend_options(opts))
end

function utils.inoremap(keymap, command, opts)
  vim.keymap.set("i", keymap, command, extend_options(opts))
end

function utils.tnoremap(keymap, command, opts)
  vim.keymap.set("t", keymap, command, extend_options(opts))
end

function utils.xnoremap(keymap, command, opts)
  vim.keymap.set("x", keymap, command, extend_options(opts))
end

function utils.vnoremap(keymap, command, opts)
  vim.keymap.set("v", keymap, command, extend_options(opts))
end

function utils.is_git_repo()
  vim.fn.system("git rev-parse --is-inside-work-tree")
  return vim.v.shell_error == 0
end

function utils.get_git_root()
  local dot_git_path = vim.fn.finddir(".git", ".;")
  return vim.fn.fnamemodify(dot_git_path, ":h")
end

function utils.print_table(t, indent)
  indent = indent or 0
  for k, v in pairs(t) do
    formatting = string.rep(" ", indent) .. k .. ": "
    if type(v) == "table" then
      print(formatting)
      utils.print_table(v, indent + 2)
    else
      print(formatting .. tostring(v))
    end
  end
end

function utils.get_git_root_with_fallback()
  vim.fn.system("git rev-parse --is-inside-work-tree")

  if not vim.v.shell_error == 0 then
    local cwd = vim.loop.cwd()
    return cwd
  end

  local dot_git_path = vim.fn.finddir(".git", ".;")
  return vim.fn.fnamemodify(dot_git_path, ":h")
end

local nnoremap = utils.nnoremap
local tnoremap = utils.tnoremap
local vnoremap = utils.vnoremap
local xnoremap = utils.xnoremap

vim.g.mapleader = " "

vim.cmd([[
if executable("rg")
  set grepprg=rg\ --vimgrep\ --smart-case\ --hidden\ --column
  set grepformat=%f:%l:%c:%m
endif


" open quickfix list as soon as items are inserted
augroup quickfix
    autocmd!
    autocmd QuickFixCmdPost [^l]* cwindow
    autocmd QuickFixCmdPost l* lwindow
augroup END

set iskeyword+=-
set path=**
]])

vim.g.lazyvim_check_order = false
vim.g.gutentags_enabled = 0
vim.g.rooter_manual_only = 1
vim.g.editorconfig = false
vim.opt.guicursor = ""
vim.opt.updatetime = 200
vim.opt.laststatus = 3

vim.o.foldenable = true
vim.o.foldmethod = "indent"
vim.o.foldlevelstart = 99

vim.o.fileencodings = "utf-8"
vim.o.autoread = true

vim.o.completeopt = "menuone,noselect,noinsert"
vim.o.wrap = true
vim.o.linebreak = true
vim.o.conceallevel = 1
vim.o.swapfile = false
vim.o.backup = false
vim.o.writebackup = false

vim.o.undodir = vim.fn.getenv("HOME") .. "/.vim/undodir"
vim.o.undofile = true

vim.o.errorbells = false

vim.o.scrolloff = 8
vim.o.numberwidth = 2

vim.o.autochdir = true
vim.o.number = true
vim.o.relativenumber = false

vim.o.hidden = true
vim.o.splitright = true
vim.o.splitbelow = true

vim.o.hlsearch = true

vim.o.ignorecase = true
vim.o.smartcase = true
vim.o.smartindent = true
vim.o.expandtab = true
vim.o.tabstop = 2
vim.o.softtabstop = 2
vim.o.shiftwidth = 2
vim.g.colorcolumn = 120
vim.o.pumheight = 30

vim.wo.signcolumn = "yes"

vim.o.cmdheight = 1

vim.g.netrw_browse_split = 0
vim.g.netrw_banner = 1
vim.g.netrw_winsize = 25

local highlight_group = vim.api.nvim_create_augroup("YankHighlight", { clear = true })
vim.api.nvim_create_autocmd("TextYankPost", {
  callback = function()
    vim.highlight.on_yank()
  end,
  group = highlight_group,
  pattern = "*",
})

vim.cmd [[command! -nargs=1 Browse silent execute '!open' shellescape(<q-args>,1)]]

local json_group = vim.api.nvim_create_augroup("JsonSyntaxOff", { clear = true })
vim.api.nvim_create_autocmd("FileType", {
  callback = function()
    if vim.bo.filetype == "json" then
      vim.opt_local.syntax = "off"
    end
  end,
  group = json_group,
  pattern = "*",
})

nnoremap("<C-u>", "<C-u>zz")
nnoremap("<C-d>", "<C-d>zz")

nnoremap("<leader><Enter>", ":so %<cr>")
nnoremap("<leader>co", ":vsp ~/.dotfiles/nixos/modules/nvim/kickstart-init.lua<cr>")
nnoremap("<leader>to", "viw~<cr>")

nnoremap("<leader>gs", ":vert G<cr>")
nnoremap("<leader>gh", ":diffget //2<cr>")
nnoremap("<leader>gl", ":diffget //3<cr>")

tnoremap("<Esc>", "<C-><C-n><CR>")

vnoremap("<leader>r", ":RunCodeSelected<CR>")
nnoremap("<leader>rr", ":RunCodeFile<CR>")

xnoremap("<leader>y", '"+y')
nnoremap("<leader>p", '"+p')
xnoremap("<leader>p", '"+p')
xnoremap("<leader>P", '"+P')
nnoremap("<leader>P", '"+P')

nnoremap("<leader>ql", ":cnext<CR>")
nnoremap("<leader>qh", ":cprev<CR>")

nnoremap("<leader>bl", ":bnext<CR>")
nnoremap("<leader>bh", ":bprevious<CR>")

local function link_open_in_browser()
  local str_link = vim.fn.expand("<cWORD>")
  local url = str_link:match("%(([^)]+)%)")
  print("Opening link: " .. url)
  vim.fn.jobstart("open " .. url, { detach = true })
end
nnoremap("<leader>lat", link_open_in_browser)

vim.cmd([[
function! NumberToggle()
    if(&nu == 1)
        set nu!
        set rnu
    else
        set nornu
        set nu
    endif
endfunction

nnoremap <leader>8 :call NumberToggle()<CR>
]])

nnoremap("[d", vim.diagnostic.goto_prev)
nnoremap("]d", vim.diagnostic.goto_next)
nnoremap("<leader>q", vim.diagnostic.setloclist)

local IsTransparent = false

local function turn_background_transparent()
  vim.cmd [[
      highlight Normal guibg=none
      highlight NonText guibg=none
      highlight Normal ctermbg=none
      highlight NonText ctermbg=none
    ]]
end

local function color_my_pencils(transparent)
  local _transparent = transparent or false

  local colorscheme = "kanagawa"
  local ok, error = pcall(function()
    vim.cmd(string.format('colorscheme %s', colorscheme))
  end)

  if not ok then
    print(string.format('Error loading colorscheme: %s', error))
    vim.cmd [[colorscheme default]]
  end

  for _, group in ipairs(vim.fn.getcompletion("@lsp", "highlight")) do
    vim.api.nvim_set_hl(0, group, {})
  end

  if _transparent then
    turn_background_transparent()
  end
end

local function init_colorscheme()
  color_my_pencils(IsTransparent)
end

init_colorscheme()

nnoremap('<leader>tb', function()
  IsTransparent = not IsTransparent
  color_my_pencils(IsTransparent)
end)

local function clear_buffer(buf_nbr)
  vim.api.nvim_buf_set_lines(buf_nbr, 0, -1, false, { "" })
end

local function output_buffer(buf_nbr, data)
  vim.api.nvim_buf_set_lines(buf_nbr, -1, -1, false, data)
end

local function attatch_buff_number(buffer_number, pattern, command)
  vim.api.nvim_create_autocmd("BufWritePost", {
    group = vim.api.nvim_create_augroup("WesDev", { clear = true }),
    pattern = pattern,
    callback = function()
      clear_buffer(buffer_number)
      local append_buffer = function(_, data)
        output_buffer(buffer_number, data)
      end
      vim.fn.jobstart(command, {
        stdout_buffered = true,
        on_stdout = append_buffer,
        on_stderr = append_buffer,
      })
    end,
  })
end

local function split_into_new_buffer()
  vim.cmd("vsplit")
  local win = vim.api.nvim_get_current_win()
  local buf = vim.api.nvim_create_buf(true, true)
  vim.api.nvim_win_set_buf(win, buf)
  return buf
end

local function create_playground(name, pattern, command)
  vim.api.nvim_create_user_command(name, function()
    local run_buffer = split_into_new_buffer()
    attatch_buff_number(tonumber(run_buffer), pattern, command)
  end, {})
end

vim.api.nvim_create_user_command("AutoRun", function()
  local run_buffer = split_into_new_buffer()
  local pattern = vim.fn.input("Pattern: ")
  local command = vim.split(vim.fn.input("Command: "), " ")

  attatch_buff_number(tonumber(run_buffer), pattern, command)
end, {})

create_playground("TSPlayground", "*.ts", "node --no-warnings playground.ts")
create_playground("BashPlayground", "*.sh", "bash playground.sh")

vim.opt.termguicolors = true

require('kanagawa').setup({
  compile = false,
  undercurl = true,
  commentStyle = { italic = true },
  functionStyle = {},
  keywordStyle = { italic = true },
  statementStyle = { bold = true },
  typeStyle = {},
  transparent = false,
  dimInactive = false,
  terminalColors = true,
  colors = {},
  overrides = function(colors)
    local theme = colors.theme
    local makeDiagnosticColor = function(color)
      local c = require("kanagawa.lib.color")
      return { fg = color, bg = c(color):blend(theme.ui.bg, 0.95):to_hex() }
    end

    return {
      DiagnosticVirtualTextHint = makeDiagnosticColor(theme.diag.hint),
      DiagnosticVirtualTextInfo = makeDiagnosticColor(theme.diag.info),
      DiagnosticVirtualTextWarn = makeDiagnosticColor(theme.diag.warning),
      DiagnosticVirtualTextError = makeDiagnosticColor(theme.diag.error),
    }
  end,
  theme = "wave",
  background = {
    dark = "wave",
    light = "lotus",
  },
})

vim.cmd.colorscheme("kanagawa")

local diagnostic_signs = {
  Error = " ",
  Warn = " ",
  Hint = " ",
  Info = " ",
}

for type, icon in pairs(diagnostic_signs) do
  local hl = "DiagnosticSign" .. type
  vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = hl })
end

vim.diagnostic.config({
  signs = {
    text = {
      [vim.diagnostic.severity.ERROR] = diagnostic_signs.Error,
      [vim.diagnostic.severity.WARN] = diagnostic_signs.Warn,
      [vim.diagnostic.severity.INFO] = diagnostic_signs.Info,
      [vim.diagnostic.severity.HINT] = diagnostic_signs.Hint,
    },
  },
})

local cmp = require('blink.cmp')

cmp.setup({
  keymap = { preset = 'enter' },
  appearance = {
    use_nvim_cmp_as_default = true,
    nerd_font_variant = 'mono'
  },
  completion = {
    accept = { auto_brackets = { enabled = true } }
  },
  sources = {
    default = { 'lsp', 'path', 'snippets', 'buffer' },
  },
})

local on_attach = function(client, bufnr)
  local opts = { buffer = bufnr, remap = false }

  vim.keymap.set("n", "gd", function() vim.lsp.buf.definition() end, opts)
  vim.keymap.set("n", "K", function() vim.lsp.buf.hover() end, opts)
  vim.keymap.set("n", "<leader>vws", function() vim.lsp.buf.workspace_symbol() end, opts)
  vim.keymap.set("n", "<leader>vd", function() vim.diagnostic.open_float() end, opts)
  vim.keymap.set("n", "<leader>vca", function() vim.lsp.buf.code_action() end, opts)
  vim.keymap.set("n", "<leader>vrr", function() vim.lsp.buf.references() end, opts)
  vim.keymap.set("n", "<leader>vrn", function() vim.lsp.buf.rename() end, opts)
  vim.keymap.set("i", "<C-h>", function() vim.lsp.buf.signature_help() end, opts)
end

vim.lsp.enable('lua_ls', {
  on_attach = on_attach,
  capabilities = cmp.get_lsp_capabilities(),
})

vim.lsp.enable('ts_ls', {
  on_attach = on_attach,
  capabilities = cmp.get_lsp_capabilities(),
})

vim.lsp.enable('pyright', {
  on_attach = on_attach,
  capabilities = cmp.get_lsp_capabilities(),
})

require('fidget').setup({})

local builtin = require('telescope.builtin')
vim.keymap.set('n', '<leader>ff', builtin.find_files, {})
vim.keymap.set('n', '<leader>fg', builtin.live_grep, {})
vim.keymap.set('n', '<leader>fb', builtin.buffers, {})
vim.keymap.set('n', '<leader>fh', builtin.help_tags, {})

vim.keymap.set('n', '<leader>e', vim.diagnostic.open_float)
vim.keymap.set('n', '[d', vim.diagnostic.goto_prev)
vim.keymap.set('n', ']d', vim.diagnostic.goto_next)
vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist)

require('todo-comments').setup()

require('gitsigns').setup()

local conform = require("conform")
conform.setup({
  formatters_by_ft = {
    lua = { "stylua" },
    python = { "isort", "black" },
    javascript = { { "prettierd", "prettier" } },
    typescript = { { "prettierd", "prettier" } },
    javascriptreact = { { "prettierd", "prettier" } },
    typescriptreact = { { "prettierd", "prettier" } },
    css = { "prettier" },
    html = { "prettier" },
    json = { "prettier" },
    yaml = { "prettier" },
    markdown = { "prettier" },
  },
})

vim.keymap.set({ "n", "v" }, "<leader>mp", function()
  conform.format({
    lsp_fallback = true,
    async = false,
    timeout_ms = 500,
  })
end, { desc = "Format file or range (in visual mode)" })

vim.api.nvim_create_autocmd('FileType', {
  pattern = { 'bash', 'c', 'diff', 'html', 'lua', 'luadoc', 'markdown', 'markdown_inline', 'query', 'vim', 'vimdoc', 'javascript', 'typescript' },
  callback = function()
    if pcall(vim.treesitter.start) then
      vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
    end
  end,
})

-- Oil file explorer
require('oil').setup({
  columns = { "icon" },
  buf_options = {
    buflisted = false,
    bufhidden = "hide",
  },
  win_options = {
    wrap = false,
    signcolumn = "no",
    cursorcolumn = false,
    spell = false,
    list = false,
  },
  default_file_explorer = true,
  delete_to_trash = false,
  view_options = {
    show_hidden = true,
  },
})

vim.keymap.set('n', '-', oil.open, { desc = 'Open file explorer' })
vim.keymap.set('n', '<leader>pt', function()
  vim.cmd(':Oil')
end, { desc = 'Toggle file explorer' })

-- Snacks (scratch buffer + notifier)
require('snacks').setup({
  bigfile = { enabled = true },
  notifier = { enabled = true },
  quickfile = { enabled = true },
})

vim.keymap.set('n', '<C-t>', function()
  Snacks.scratch()
end, { desc = 'Toggle scratch buffer' })
vim.keymap.set('n', '<leader>sch', function()
  Snacks.notifier.show_history()
end, { desc = 'Show notification history' })

-- Diffview for git diffs
require('diffview').setup({})

vim.keymap.set('n', '<leader>dfo', ':DiffviewOpen<CR>', { desc = 'Open diffview' })
vim.keymap.set('n', '<leader>dff', ':DiffviewFileHistory %<CR>', { desc = 'Open file history' })
vim.keymap.set('n', '<leader>dfx', ':DiffviewClose<CR>', { desc = 'Close diffview' })

-- Git blame
require('gitsigns').setup({
  current_line_blame = true,
  current_line_blame_opts = {
    delay = 0,
  },
})

vim.keymap.set('n', '<leader>ba', ':GitBlameToggle<CR>', { desc = 'Toggle git blame' })

-- Comments
require('Comment').setup()

print("Neovim configuration loaded with Kanagawa colorscheme!")
