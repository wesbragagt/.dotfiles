function! ToggleQuickFix()
    if getqflist({'winid' : 0}).winid
        cclose
    else
        copen
    endif
endfunction

command! -nargs=0 -bar ToggleQuickFix call ToggleQuickFix()
command! -nargs=0 -bar ClearQuickFix call setqflist([])

nnoremap <leader>q :ToggleQuickFix<cr>
nnoremap <leader>qq :ClearQuickFix<cr>
" quickfix navigation
nnoremap <leader>l :cnext<CR>
nnoremap <leader>h :cprev<CR>
nnoremap <leader>q :copen<CR>
