let mapleader = ' '
nnoremap <leader><Enter> :so %<CR>
" Reload lua modules
nnoremap <leader>r <cmd>lua require("plenary.reload").reload_module("wesbragagt")<CR>

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
command! ConfigVim vsp ~/.dotfiles/nvim/.config/nvim
nnoremap <leader>co :ConfigVim<CR>
" toggle between uppercase and lowercase 
nnoremap <leader>to viw~<CR>
" run ts-node on the current file
nnoremap <leader>ts :!ts-node %<CR>
" run go on the current file
nnoremap <leader>go :!go run %<CR>
" run current shell file 
nnoremap <leader>sh :!zsh %<CR>
" quickfix navigation
nnoremap <C-l> :cnext<CR>
nnoremap <C-h> :cprev<CR>
nnoremap <leader>qf :copen<CR>
" Bufferline close current buffer
nnoremap <leader>x :bdelete<CR>
nnoremap <leader>x :!chmod +x %<CR>

" simple command to copy all search matches to the clipboard
function! CopyMatches(reg)
  let hits = []
  %s//\=len(add(hits, submatch(0))) ? submatch(0) : ''/gne
  let reg = empty(a:reg) ? '+' : a:reg
  execute 'let @'.reg.' = join(hits, "\n") . "\n"'
endfunction
command! -register CopyMatches call CopyMatches(<q-reg>)
" convert json object to typescript interface
xnoremap <leader>ty :!npx json-ts --stdin<CR>
" Clipboard
" Copy to system clipboard
xnoremap <silent><leader>y "+y<CR>
nnoremap <silent><leader>yy "+yy<CR>
nnoremap <silent><leader>p "+p<CR>
" Paste from system clipboard
xnoremap <silent><leader>p "+p<CR>
nnoremap <silent><leader>P "+P<CR>
xnoremap <silent><leader>P "+P<CR>
" JsDoc
nnoremap <silent><C-l> :JsDoc<CR>

" Telescope
nnoremap <leader>ff <cmd>lua require("wesbragagt._telescope").my_git_files()<CR>
nnoremap <leader>fi <cmd>lua require("wesbragagt._telescope").my_find_files()<CR>
nnoremap <leader>fg <cmd>Telescope live_grep<CR>
nnoremap <leader>fb <cmd>Telescope buffers<CR>
nnoremap <leader>fgb <cmd>Telescope git_branches<CR>

" LSP
nnoremap <silent>gd <cmd>lua vim.lsp.buf.definition()<CR>
nnoremap <silent>gr <cmd>lua vim.lsp.buf.references()<CR>
nnoremap <silent>ca <cmd>lua vim.lsp.buf.code_action()<CR>
nnoremap <silent>K <cmd>lua vim.lsp.buf.hover()<CR>
nnoremap <leader>fo :Format<CR>
nnoremap <leader>lsp :LspInstallInfo<CR>

"Debug
nnoremap <leader>dd :call vimspector#Launch()<CR>
