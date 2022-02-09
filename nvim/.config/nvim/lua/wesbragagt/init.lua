-- Speed up neovim startup
require("impatient")
-- Do not source the default filetype.vim
vim.g.did_load_filetypes = 1
require("wesbragagt._colorscheme")
require("wesbragagt._telescope")
require("wesbragagt._lsp")
require("wesbragagt._formatter")
require("wesbragagt._treesitter")
require("wesbragagt._toggleterm")
require("wesbragagt._lualine")
require("wesbragagt._gitsigns")
require("wesbragagt._bufferline")
require("wesbragagt._icons")

