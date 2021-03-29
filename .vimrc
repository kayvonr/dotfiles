syntax on
filetype plugin indent on

autocmd FileType python set complete+=k~/.vim/syntax/python.vim 
syntax enable

"keep the cursor in the middle of the page
set scrolloff=80
"relative numbering
set relativenumber
" also set absolute, which just shows current line's absolute number
set number
"if you print from vim: single sided, 14pt margins, with line numbers
set printoptions=duplex:off,left:14pt,number:y
"start searching while typing
set incsearch

set background=dark
"colorscheme solarized8
let g:solarized_termcolors=16

"close vim if only NERDTree window left open
autocmd bufenter * if (winnr("$") == 1 && exists("b:NERDTree") && b:NERDTree.isTabTree()) | q | endif
"shortcut to turn on NERDTree
command Nerd NERDTree
"disable the arrows that don't work
let g:NERDTreeDirArrows=0
" have nerdtree show hidden files
let NERDTreeShowHidden=1
" sort dotfiles first in directories
let NERDTreeSortHiddenFirst=1

au FileType python set omnifunc=pythoncomplete#Complete textwidth=90
autocmd FileType javascript set omnifunc=javascriptcomplete#CompleteJS textwidth=90
autocmd FileType html set omnifunc=htmlcomplete#CompleteTags textwidth=90
au FileType css set omnifunc=csscomplete#CompleteCSS textwidth=90
autocmd FileType xml set omnifunc=xmlcomplete#CompleteTags textwidth=90
autocmd FileType php set omnifunc=phpcomplete#CompletePHP textwidth=90
autocmd FileType c set omnifunc=ccomplete#Complete textwidth=90
autocmd FileType pyrex set expandtab shiftwidth=4 softtabstop=4 autoindent textwidth=90
autocmd FileType json set expandtab shiftwidth=4 softtabstop=4 autoindent
autocmd FileType text set expandtab shiftwidth=4 softtabstop=4 autoindent textwidth=0
autocmd FileType yaml set expandtab shiftwidth=2 softtabstop=2 autoindent
autocmd FileType ruby set expandtab shiftwidth=2 softtabstop=2 autoindent textwidth=90
autocmd FileType sh set expandtab shiftwidth=4 softtabstop=4 autoindent textwidth=0
autocmd FileType sql set expandtab shiftwidth=4 softtabstop=4 autoindent textwidth=0

let g:SuperTabDefaultCompletionType = "context"
set completeopt=menuone,longest
set completeopt-=preview
autocmd FileType python setlocal completeopt-=preview


"Set the leader and change exit from esc to jj 
let mapleader = ","
inoremap jj <ESC>

set isk+=.
set backspace=indent,eol,start
set nocompatible
set ignorecase
set autoindent
set copyindent
set smartcase
set viminfo='10,\"100,:20,%,n~/.viminfo
"set textwidth=90
set softtabstop=4
set tabstop=4
set expandtab
set smarttab

"puts a red column at XXchars
set colorcolumn=90

autocmd BufNewFile,BufRead *.json set ft=javascript
autocmd BufNewFile,BufRead *.conf set ft=javascript
autocmd BufNewFile,BufRead *.config set ft=javascript

au! BufRead,BufNewFile *.json setfiletype json 
au! BufRead,BufNewFile *.conf setfiletype json 
au! BufRead,BufNewFile *.config setfiletype json 

au BufRead,BufNewFile *py,*pyw,*.c,*.h set tabstop=4
au BufRead,BufNewFile *.py,*pyw set shiftwidth=4
au BufRead,BufNewFile *.conf set shiftwidth=2
au BufRead,BufNewFile *.py,*.pyw set expandtab

"nice status bar at bottom with current/total lines, column, percent of doc
set statusline=%<\ %n:%f\ %m%r%y%=%-35.(line:\ %l\ of\ %L,\ col:\ %c%V\ (%P)%)
:set laststatus=2

nmap <silent> <C-f> :CommandTFlush<CR>
nmap <C-k> D
nmap <C-y> p

"semi-colon is a colon
nnoremap ; :

"Disable the arrows to force me to learn
nnoremap <up> <nop>
nnoremap <down> <nop>
nnoremap <left> <nop>
nnoremap <right> <nop>
nnoremap j gj
nnoremap k gk
nnoremap t l
xnoremap t l

"Saving and quiting short-cuts
nnoremap <leader>w :w<CR>
nnoremap <leader>wq :wq<CR>
nnoremap <leader>q :q<CR>
nnoremap <leader>qq :q!<CR>

"shortcuts for paste 'mode'
nnoremap <leader>p :set paste<CR>
nnoremap <leader>np :set nopaste<CR>

"hl search highlights as you search
set hlsearch
nnoremap <leader>k :nohlsearch<CR>

" Folding set up 
set foldmethod=indent
set nofoldenable
nnoremap <leader>l zR
nnoremap <leader>m zM

nnoremap <leader>f :CommandTFlush<CR>
" remap the nerdcommenter toggle to just leader c
nnoremap <leader>a :Ack
nnoremap <F5> :GundoToggle<CR>

"Easier splits navigation - Remapped Caps Lock to Control
nnoremap <C-h> <C-w>h
nnoremap <C-j> <C-w>j
nnoremap <C-k> <C-w>k
nnoremap <C-l> <C-w>l
nnoremap <C-t> <C-w>l
nnoremap <leader>v <C-w>v<C-w>l
nnoremap <leader>d <C-w>-
nnoremap <leader>< <C-w><
nnoremap <leader>> <C-w>>
nnoremap <leader>k <C-w>+
nnoremap <leader>h :split<CR>


let g:jedi#popup_on_dot = 0

command! Despace :%s/\s\+$//
