let g:VimuxHeight = "40"
let g:VimuxOrientation = "h"
" Runs the specified command inside the directory of the currently opened file. Takes two arguments. command and inFile
nnoremap <leader>t :call VimuxRunCommandInDir("clear; yarn jest --runInBand", 1)<CR>
" Close the tmux runner created
nnoremap <leader>vq :VimuxCloseRunner<CR>

function VimuxPromptCommandDir()
  execute 'RooterToggle' 
  execute 'VimuxPromptCommand'
  execute 'RooterToggle'
endfunction

" Prompt for a command to run
nnoremap <leader>vp :call VimuxPromptCommandDir()<CR>
