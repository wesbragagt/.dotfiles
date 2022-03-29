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
nnoremap <silent><C-n> :cnext<CR>
nnoremap <silent><C-p> :cprev<CR>
nnoremap <leader>q :copen<CR>
