local utils = require("utils")

local nnoremap = utils.nnoremap
local tnoremap = utils.tnoremap
local vnoremap = utils.vnoremap
local xnoremap = utils.xnoremap

vim.g.mapleader = " "

-- go up and down half page and center cursor
nnoremap("<C-u>", "<C-u>zz")
nnoremap("<C-d>", "<C-d>zz")

nnoremap("<leader><Enter>", ":so %<cr>") -- source current file
nnoremap("<leader>co", ":vsp ~/.dotfiles/nvim/.config/nvim<cr>") -- open nvim config directory in a split
nnoremap("<leader>to", "viw~<cr>") -- uppercase current word

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

vim.cmd([[
" Relative or absolute number lines
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

-- Renaming references in buffer
nnoremap("<leader>rb", vim.lsp.buf.rename)

local function replace_on_quickfix_list()
	local ok, replacer = pcall(require, "replacer")
	if not ok then
		return
	end

	replacer.run()
end

-- Replacer quickfix list
nnoremap("<leader>rm", replace_on_quickfix_list)

-- Diagnostic keymaps
nnoremap("[d", vim.diagnostic.goto_prev)
nnoremap("]d", vim.diagnostic.goto_next)
nnoremap("<leader>q", vim.diagnostic.setloclist)

-- Explorer
nnoremap("<leader>pt", function()
	vim.cmd(":Ex")
end)
