lua <<EOF
require'nvim-treesitter.configs'.setup {
  indenting = {
    enable = true
    }, 
  highlight = { 
    enable = true 
    }, 
  incremental_selection = { 
    enable = true 
    }, 
  textobjects = { 
    enable = true 
  }
}
EOF
