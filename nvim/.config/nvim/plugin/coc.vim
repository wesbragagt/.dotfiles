" Add `:Format` command to format current buffer.
command! -nargs=0 Format :call CocAction('format')
" Format shortcut
nnoremap <leader>fo :Format<CR>
" import module on cursor
nnoremap <C-Space> :CocAction<CR>
if isdirectory('./node_modules') && isdirectory('./node_modules/prettier')
  let g:coc_global_extensions += ['coc-prettier']
endif

if isdirectory('./node_modules') && isdirectory('./node_modules/eslint')
  let g:coc_global_extensions += ['coc-eslint']
endif

let mapleader = ' '
" go to definition
nmap <silent> gd <Plug>(coc-definition)
nmap <silent> gy <Plug>(coc-type-definition)
nmap <silent> gi <Plug>(coc-implementation)
nmap <silent> gr <Plug>(coc-references)
nnoremap <silent> K :call CocAction('doHover')<CR>
" CoC diagnostic
nnoremap <leader>di :CocDiagnostics<CR>
