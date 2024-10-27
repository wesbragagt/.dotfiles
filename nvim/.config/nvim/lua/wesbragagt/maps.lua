local utils = require("utils")

local nnoremap = utils.nnoremap
local tnoremap = utils.tnoremap
local vnoremap = utils.vnoremap
local xnoremap = utils.xnoremap

vim.g.mapleader = " "

-- go up and down half page and center cursor
nnoremap("<C-u>", "<C-u>zz")
nnoremap("<C-d>", "<C-d>zz")

nnoremap("<leader><Enter>", ":so %<cr>")                         -- source current file
nnoremap("<leader>co", ":vsp ~/.dotfiles/nvim/.config/nvim<cr>") -- open nvim config directory in a split
nnoremap("<leader>to", "viw~<cr>")                               -- uppercase current word

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

-- Clipboard
xnoremap("<leader>y", '"+y') -- copy selection to system clipboard
nnoremap("<leader>p", '"+p') -- paste from system clipboard below
xnoremap("<leader>p", '"+p') -- paste from system clipboard into selection below
xnoremap("<leader>P", '"+P') -- paste from system clipboard into selection above
nnoremap("<leader>P", '"+P') -- paste from system clipboard above

-- Diffview
nnoremap("<leader>dfo", ":DiffviewOpen<CR>")
nnoremap("<leader>dff", ":DiffviewFileHistory %<CR>")
nnoremap("<leader>dfx", ":DiffviewClose<CR>")

-- Quickfix Navigation
nnoremap("<leader>ql", ":cnext<CR>")
nnoremap("<leader>qh", ":cprev<CR>")

-- Buffer Navigation
nnoremap("<leader>bl", ":bnext<CR>")
nnoremap("<leader>bh", ":bprevious<CR>")

-- Hover link open in browser

local function link_open_in_browser()
  -- Get the current link under the cursor
  local str_link = vim.fn.expand("<cWORD>")
  -- Match just the inside of (http|https://link.com)
  local url = str_link:match("%(([^)]+)%)")
  print("Opening link: " .. url)
  vim.fn.jobstart("open " .. url, { detach = true })
  -- Open the link in the browser
  -- vim.fn.jobstart("open " .. link, {detach = true})
end
nnoremap("<leader>lat", link_open_in_browser)

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
  vim.cmd(":Oil")
end)

-- Markdown
nnoremap("<leader>mp", ":MarkdownPreviewToggle<CR>")

-- Toggle copilot
nnoremap("<leader>cp-", ":Copilot disable<CR>")
nnoremap("<leader>cp=", ":Copilot enable<CR>")

-- Copies all lines selected by a search for example /dude
-- first :g/pattern/y A
-- then :let @+ = @a
local function copy_lines_selected_by_search()
  -- clean up register
  vim.cmd(":let @a = ''")
  vim.cmd(":g//y A")
  -- avoid cursor from moving to last occurance
  vim.cmd(":normal! ``")
  -- clear previous yanked text
  vim.cmd(":let @+ = @a")
  -- clean up register
  vim.cmd(":let @a = ''")
end
nnoremap("<leader>vy", copy_lines_selected_by_search)
