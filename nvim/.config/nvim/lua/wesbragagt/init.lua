-- Speed up neovim startup
require("impatient")
-- Do not source the default filetype.vim
vim.g.did_load_filetypes = 1
-- @deprecated require("wesbragagt._telescope")
require("wesbragagt._lsp")
require("wesbragagt._formatter")
require("wesbragagt._treesitter")
-- @deprecated require("wesbragagt._toggleterm")
require("wesbragagt._lualine")
require("wesbragagt._gitsigns")
require("wesbragagt._bufferline")
require("wesbragagt._icons")
require("wesbragagt._diffview")
