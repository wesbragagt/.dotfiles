-- Do not source the default filetype.vim
vim.g.did_load_filetypes = 1
require("wesbragagt._filetype")
-- Speed up neovim startup
require("impatient")
-- @deprecated require("wesbragagt._telescope")
require("wesbragagt._lsp")
-- @deprecated require("wesbragagt._formatter")
require("wesbragagt._treesitter")
-- @deprecated require("wesbragagt._toggleterm")
-- @deprecated require("wesbragagt._lualine")
require("wesbragagt._gitsigns")
require("wesbragagt._bufferline")
require("wesbragagt._icons")
require("wesbragagt._diffview")
require("wesbragagt._null-ls")

require("wesbragagt._indentline")
require("wesbragagt._statusline")
