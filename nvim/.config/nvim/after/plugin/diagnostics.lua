local trouble_ok, trouble = pcall(require, "trouble")

if not trouble_ok then
  print("Plugin: trouble not found")
  return
end


trouble.setup({
  icons = {
    indent = {
      middle = " ",
      last = " ",
      top = " ",
      ws = "│  ",
    },
  },
  modes = {
    diagnostics = {
      groups = {
        { "filename", format = "{file_icon} {basename:Title} {count}" },
      },
    },
  },
})

local nnoremap = require("utils").nnoremap

nnoremap("<leader>di", "<cmd>Trouble diagnostics toggle focus=false filter.buf=0<cr>")
