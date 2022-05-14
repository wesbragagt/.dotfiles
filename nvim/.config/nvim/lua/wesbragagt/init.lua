if (vim.fn.has("termguicolors")) then
  vim.opt.termguicolors = true
end

require("wesbragagt._plugins")
-- Do not source the default filetype.vim
vim.g.did_load_filetypes = 1
require("wesbragagt._filetype")
-- Speed up neovim startup
require("impatient")
require("wesbragagt._lsp")
require("wesbragagt._treesitter")
require("wesbragagt._toggleterm")
require("wesbragagt._gitsigns")
require("wesbragagt._bufferline")
require("wesbragagt._icons")
require("wesbragagt._diffview")
require("wesbragagt._null-ls")
require("wesbragagt._indentline")
require("wesbragagt._statusline")
