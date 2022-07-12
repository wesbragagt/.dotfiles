local utils = require("utils")
local nnoremap = utils.nnoremap
local tnoremap = utils.tnoremap
local vnoremap = utils.vnoremap
local xnoremap = utils.xnoremap

vim.g.mapleader = " "

nnoremap("<leader><Enter>", ":so %<cr>") -- source current file
nnoremap("<leader>co", ":vsp ~/.dotfiles/nvim/.config/nvim") -- open nvim config directory in a split
nnoremap("<leader>to", "viw~<cr>") -- uppercase current word
nnoremap("<leader>/", ":RooterToggle<cr>") -- sets the pwd to .git root of current buffer or current file dir

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
nnoremap("gd", "<cmd>lua vim.lsp.buf.definition()<CR>")
nnoremap("gr", "<cmd>lua vim.lsp.buf.references()<CR>")
-- nnoremap("ca <cmd>lua", " vim.lsp.buf.code_action()<CR>")
nnoremap("ca", ":CodeActionMenu<CR>")
nnoremap("K", "<cmd>lua vim.lsp.buf.hover()<CR>")
nnoremap("L", "<cmd>lua vim.diagnostic.open_float()<CR>")
nnoremap("<leader>fo", '<cmd>lua vim.lsp.buf.formatting_sync(nil,"", 2000)<CR>')

-- Clipboard
xnoremap("<leader>y", ' "+y<CR>') -- copy selection to system clipboard
nnoremap("<leader>p", ' "+p<CR>') -- paste from system clipboard below
xnoremap("<leader>p", ' "+p<CR>') -- paste from system clipboard into selection below
xnoremap("<leader>P", ' "+P<CR>') -- paste from system clipboard into selection above
nnoremap("<leader>P", ' "+P<CR>') -- paste from system clipboard above
