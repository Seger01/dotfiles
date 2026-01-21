" can't set leaders in Obsidian vim, so the key just has to be used consistently.
" However, it needs to be unmapped, to not trigger default behavior: https://github.com/esm7/obsidian-vimrc-support#some-help-with-binding-space-chords-doom-and-spacemacs-fans
unmap ,

" window controls
exmap wq obcommand workspace:close<CR>
exmap q obcommand workspace:close<CR>

exmap focusRight obcommand editor:focus-right
nmap <C-w>l :focusRight<CR>

exmap focusLeft obcommand editor:focus-left
nmap <C-w>h :focusLeft<CR>

exmap focusTop obcommand editor:focus-top
nmap <C-w>k :focusTop<CR>

exmap focusBottom obcommand editor:focus-bottom
nmap <C-w>j :focusBottom<CR>

exmap splitVertical obcommand workspace:split-vertical
nmap <C-w>v :splitVertical<CR>

exmap splitHorizontal obcommand workspace:split-horizontal
nmap <C-w>s :splitHorizontal<CR>

set clipboard=unnamed

" Have j and k navigate visual lines rather than logical ones, normal mode
noremap j gj
noremap k gk
noremap gj j
noremap gk k

" use logical line navigation in visual mode
vnoremap j gj
vnoremap k gk
vnoremap gj j
vnoremap gk k

" :bnext/bprev
exmap goBack obcommand app:go-back
exmap goForward obcommand app:go-forward
nnoremap <C-o> :goBack<CR>
nnoremap <C-i> :goForward<CR>

" " " Visual mode: move selected lines using Obsidian commands
" " exmap moveLineDown obcommand editor:move-line-down
" " exmap moveLineUp obcommand editor:move-line-up
" "
" " vnoremap J :moveLineDown<CR>gv
" " vnoremap K :moveLineUp<CR>gv
" exmap movelinedown obcommand editor:move-line-down
" vnoremap J :movelinedown<CR>
" " vnoremap K ':obcommand editor:move-line-up<CR>'
"
" " noremap <C-j> :obcommand editor:move-line-down<CR>
" " noremap <C-k> :obcommand editor:move-line-up<CR>
