vim.cmd([[
if executable("rg")
  set grepprg=rg\ --vimgrep\ --smart-case\ --hidden\ --column
  set grepformat=%f:%l:%c:%m
endif


" open quickfix list as soon as items are inserted"
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
vim.g.editorconfig = false -- editorconfig is enabled by default
vim.o.guicursor = ""       -- cursor style
vim.opt.updatetime = 200
vim.opt.laststatus = 3 -- always show status line

vim.o.foldenable = true
vim.o.foldmethod = "indent"
vim.o.foldlevelstart = 99

vim.o.fileencodings = "utf-8"
vim.o.autoread = true -- automatically reload files that have been changed outside of vim

vim.o.completeopt = "menuone,noselect,noinsert"
vim.o.wrap = true      -- wrap text
vim.o.linebreak = true -- don't break in the middle of a word
vim.o.conceallevel = 1
vim.o.swapfile = false
vim.o.backup = false
vim.o.writebackup = false

vim.o.undodir = vim.fn.getenv("HOME") .. "/.vim/undodir"
vim.o.undofile = true -- enable persistent undo"

vim.o.errorbells = false

vim.o.scrolloff = 8 -- scroll half of the page
vim.o.numberwidth = 2

vim.o.autochdir = true
vim.o.number = true
vim.o.relativenumber = false

vim.o.hidden = true     -- preserve buffers
vim.o.splitright = true -- force all horizontal splits to go below current window
vim.o.splitbelow = true -- force all vertical splits to go to the right of current window

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

vim.o.cmdheight = 1 -- size of command bar

-- NETRW options
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
-- fix a problem with calling :GBrowse
-- Netrw not found. Define your own :Browse to use :GBrowse
vim.cmd [[command! -nargs=1 Browse silent execute '!open' shellescape(<q-args>,1)]]

-- if the filetype is json turn syntax off to speed up loading
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
