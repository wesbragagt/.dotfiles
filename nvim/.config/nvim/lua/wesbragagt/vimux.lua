vim.cmd([[ 
let g:VimuxHeight = "40"
let g:VimuxOrientation = "h"
" Close the tmux runner created
nnoremap <leader>vq :VimuxCloseRunner<CR>

function VimuxPromptCommandDir()
  execute 'RooterToggle' 
  execute 'VimuxPromptCommand'
  execute 'RooterToggle'
endfunction

" Prompt for a command to run
nnoremap <leader>vp :call VimuxPromptCommandDir()<CR>
]])
