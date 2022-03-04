vim.cmd [[
try
  let test#strategy = "neovim" 
  let g:test#neovim#start_normal = 1
  let test#neovim#term_position = "vert"

  function! CustomTestFile()
    execute 'RooterToggle' 
    execute 'TestFile'
    execute 'RooterToggle'
  endfunction 
  
  nnoremap <leader>t :call CustomTestFile()<CR>
  " nnoremap <silent> <leader>t :TestNearest<CR>
  " nnoremap <silent> <leader>T :TestFile<CR>
catch
  echo "vim-test not installed"
endtry
]]
