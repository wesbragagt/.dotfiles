lua << EOF
require("bufferline").setup{}
EOF
let mapleader = ' '
" These commands will navigate through buffers in order regardless of which mode you are using
" e.g. if you change the order of buffers :bnext and :bprevious will not respect the custom ordering
nnoremap <leader>bn :BufferLineCycleNext<CR>
nnoremap <leader>bp :BufferLineCyclePrev<CR>

" These commands will sort buffers by directory, language, or a custom criteria
nnoremap <leader>bse :BufferLineSortByExtension<CR>
nnoremap <leader>bsd :BufferLineSortByDirectory<CR>

