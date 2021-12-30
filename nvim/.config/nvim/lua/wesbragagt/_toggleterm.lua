local toggleterm = require("toggleterm")

toggleterm.setup {
  open_mapping = [[<c-\>]],
  start_in_insert = false,
  insert_mappings = true,
  direction = "float",
  shell = vim.o.shell
}
