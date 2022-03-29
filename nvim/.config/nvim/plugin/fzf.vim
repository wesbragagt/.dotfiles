if has("nvim")
autocmd! FileType fzf tnoremap <buffer> <esc> <c-c>
endif

" Run fzf from project root
function! s:find_git_root()
  return system('git rev-parse --show-toplevel 2> /dev/null')[:-2]
endfunction

command! ProjectFiles 
      \ call fzf#vim#files(s:find_git_root())

command! -bang -nargs=* LiveGrep
      \ call fzf#vim#grep("rg --column --line-number --no-heading --color=always --case-sensitive ".shellescape(<q-args>), 1, fzf#vim#with_preview({'options': ['--layout=reverse', '--info=inline'], 'dir': systemlist('git rev-parse --show-toplevel')[0]}), <bang>0)

nnoremap <leader>fi :ProjectFiles<CR>
nnoremap <leader>fg :LiveGrep<CR>
