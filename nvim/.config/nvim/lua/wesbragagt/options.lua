vim.cmd([[ 
if executable("rg")
    set grepprg=rg\ --vimgrep\ --no-heading
    set grepformat=%f:%l:%c:%m,%f:%l:%m
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

vim.g.editorconfig = false -- editorconfig is enabled by default
vim.o.guicursor="" -- cursor style
vim.opt.updatetime = 50

vim.o.foldenable = true
vim.o.foldmethod = "indent"
vim.o.foldlevelstart = 99

vim.o.fileencodings = "utf-8"
vim.o.autoread = true -- automatically reload files that have been changed outside of vim

vim.o.completeopt = "menuone,noselect,noinsert"
vim.o.wrap = true -- wrap text
vim.o.linebreak = true -- don't break in the middle of a word
vim.o.conceallevel = 0 -- so that ``is visible in markdown files
vim.o.swapfile = false
vim.o.backup = false
vim.o.writebackup = false

vim.o.undodir = vim.fn.getenv("HOME") .. "/.vim/undodir"
vim.o.undofile = true -- enable persistent undo"

vim.o.errorbells = false

vim.o.scrolloff = 8 -- scroll half of the page
vim.o.numberwidth = 2

vim.o.autochdir = true
vim.o.relativenumber = true

vim.o.hidden = true -- preserve buffers
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
vim.o.colorcolumn = 120
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
vim.cmd[[command! -nargs=1 Browse silent execute '!open' shellescape(<q-args>,1)]]
