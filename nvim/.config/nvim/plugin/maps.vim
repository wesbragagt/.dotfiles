let mapleader = ' '
nnoremap <leader><Enter> :so %<CR>
" Project view open
let g:NERDTreeWinPos = "right"
let NERDTreeShowHidden=1
nnoremap <leader>pt :NERDTreeToggle<CR>
" use regular escape in terminal mode
tnoremap <Esc> <C-\><C-n><CR>
" navigate between split panels
nnoremap <leader>h :wincmd h<CR>
nnoremap <leader>j :wincmd j<CR>
nnoremap <leader>k :wincmd k<CR>
nnoremap <leader>l :wincmd l<CR>
" Git stuff
" commit
" left pick merge
nmap <leader>gh :diffget //2<CR>
" right pick merge
nmap <leader>gl :diffget //3<CR>
" Status
nmap <leader>gs :G<CR>
" open this configuration file in split from anywhere
command! ConfigVim vsp ~/.dotfiles/nvim/.config/nvim/init.vim
nnoremap <leader>co :ConfigVim<CR>
" toggle between uppercase and lowercase 
nnoremap <leader>to g~w<CR>
" run ts-node on the current file
nnoremap <leader>ts :!ts-node %<CR>
" run go on the current file
nnoremap <leader>go :!go run %<CR>
" run current shell file 
nnoremap <leader>sh :!zsh %<CR>
" quickfix navigation
nnoremap <leader>qn :cnext<CR>
nnoremap <leader>qp :cprev<CR>
nnoremap <leader>qo :copen<CR>
" location list navigation
nnoremap <leader>ln :lnext<CR>
nnoremap <leader>lp :lprev<CR>
nnoremap <leader>lo :lopen<CR>
" Bufferline close current buffer
nnoremap <leader>x :bdelete<CR>
" Format shortcut
nnoremap <leader>fo :Format<CR>
nnoremap <leader>x :!chmod +x %<CR>

" simple command to copy all search matches to the clipboard
function! CopyMatches(reg)
  let hits = []
  %s//\=len(add(hits, submatch(0))) ? submatch(0) : ''/gne
  let reg = empty(a:reg) ? '+' : a:reg
  execute 'let @'.reg.' = join(hits, "\n") . "\n"'
endfunction
command! -register CopyMatches call CopyMatches(<q-reg>)
