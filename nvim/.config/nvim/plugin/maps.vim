let mapleader = ' '
nnoremap <leader><Enter> :so %<CR>
" Reload lua modules
nnoremap <leader>r <cmd>lua require("plenary.reload").reload_module("wesbragagt", true)<CR>

" use regular escape in terminal mode
tnoremap <Esc> <C-\><C-n><CR>
" Git stuff
" commit
" left pick merge
nmap <leader>gh :diffget //2<CR>
" right pick merge
nmap <leader>gl :diffget //3<CR>
" Status
nmap <leader>gs :vert G<CR>
nnoremap <silent>ba :GitBlameToggle<CR>
" open this configuration file in split from anywhere
command! ConfigVim vsp ~/.dotfiles/nvim/.config/nvim
nnoremap <leader>co :ConfigVim<CR>
" toggle between uppercase and lowercase 
nnoremap <leader>to viw~<CR>
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

" LSP
nnoremap <silent>gd <cmd>lua vim.lsp.buf.definition()<CR>
nnoremap <silent>gr <cmd>lua vim.lsp.buf.references()<CR>
" nnoremap <silent>ca <cmd>lua vim.lsp.buf.code_action()<CR>
nnoremap <silent>ca :CodeActionMenu<CR>
nnoremap <silent>K <cmd>lua vim.lsp.buf.hover()<CR>
nnoremap <silent>L <cmd>lua vim.diagnostic.open_float()<CR>
nnoremap <leader>fo <cmd>lua vim.lsp.buf.formatting_sync(nil, 2000)<CR>

"Debug
nnoremap <leader>dd :call vimspector#Launch()<CR>

"Rooter
nnoremap <leader>/ :RooterToggle<CR>

"Telescope
" nnoremap <leader>fg <cmd>lua require'wesbragagt._telescope'.grep()<CR> 
" nnoremap <leader>fi <cmd>lua require'wesbragagt._telescope'.project_files()<CR> 
