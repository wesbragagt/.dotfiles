lua <<EOF
require('telescope').setup{ 
  defaults = { 
    file_ignore_patterns = {
      "node_modules", ".git"
      } 
    }, 
  extensions = {
    fzf = {
      fuzzy = false,                    -- false will only do exact matching
      override_generic_sorter = true,  -- override the generic sorter
      override_file_sorter = true,     -- override the file sorter
      case_mode = "smart_case",        -- or "ignore_case" or "respect_case"
    }
  } 
}
EOF
" Find files using Telescope command-line sugar.
nnoremap <leader>ff <cmd>Telescope find_files<CR>
nnoremap <leader>fg <cmd>Telescope live_grep<CR>
nnoremap <leader>fb <cmd>Telescope buffers<CR>
nnoremap <leader>fgb <cmd>Telescope git_branches<CR>
