local utils = require("utils")
local nnoremap = utils.nnoremap
local tnoremap = utils.tnoremap
local vnoremap = utils.vnoremap
local xnoremap = utils.xnoremap

vim.g.mapleader = " "

nnoremap("<leader><Enter>", ":so %<cr>") -- source current file
nnoremap("<leader>co", ":vsp ~/.dotfiles/nvim/.config/nvim<cr>") -- open nvim config directory in a split
nnoremap("<leader>to", "viw~<cr>") -- uppercase current word
nnoremap("<leader>/", ":RooterToggle<cr>") -- sets the pwd to .git root of current buffer or current file dir

-- Open git status split
nnoremap("<leader>gs", ":vert G<cr>")
-- Git diff pick left or right
nnoremap("<leader>gh", ":diffget //2<cr>")
nnoremap("<leader>gl", ":diffget //3<cr>")
nnoremap("<silent>ba", ":GitBlameToggle<CR>")

-- Terminal
tnoremap("<Esc>", "<C-><C-n><CR>") -- Escape using ESC

-- Run snippets of code
vnoremap("<leader>r", ":RunCodeSelected<CR>")
nnoremap("<leader>rr", ":RunCodeFile<CR>")

-- LSP
nnoremap("gd", vim.lsp.buf.definition)
nnoremap("gr", vim.lsp.buf.references)
nnoremap("ca", ":CodeActionMenu<CR>")
nnoremap("K", vim.lsp.buf.hover)
nnoremap("L", vim.diagnostic.open_float)
nnoremap("<leader>fo", vim.lsp.buf.formatting_sync)

-- Clipboard
xnoremap("<leader>y", '"+y') -- copy selection to system clipboard
nnoremap("<leader>p", '"+p') -- paste from system clipboard below
xnoremap("<leader>p", '"+p') -- paste from system clipboard into selection below
xnoremap("<leader>P", '"+P') -- paste from system clipboard into selection above
nnoremap("<leader>P", '"+P') -- paste from system clipboard above

-- Diffview
nnoremap("<leader>dfo", ":DiffviewOpen<CR>")
nnoremap("<leader>dfx", ":DiffviewClose<CR>")

-- Quickfix Navigation
nnoremap("<leader>l", ":cnext<CR>")
nnoremap("<leader>h", ":cprev<CR>")
