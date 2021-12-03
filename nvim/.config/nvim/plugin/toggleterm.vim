lua <<EOF
local toggleterm = require("toggleterm")

toggleterm.setup{
  open_mapping=[[<c-\>]],
  start_in_insert = false,
  insert_mappings = true,
  direction = 'float',
  shell = vim.o.shell
}
EOF

let mapleader = ' '
nnoremap <leader>t1 :1TermExec cmd=""<left>
nnoremap <leader>t2 :2TermExec cmd=""<left>
nnoremap <leader>t3 :3TermExec cmd=""<left>
nnoremap <leader>t4 :4TermExec cmd=""<left>
