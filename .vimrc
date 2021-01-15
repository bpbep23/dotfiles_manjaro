" vim: foldmethod=marker
" vimrc
"General configration{{{
filetype plugin indent on

set termguicolors
set ignorecase
set clipboard=unnamedplus
set hlsearch
set laststatus=1
set showtabline=0
set shiftwidth=2
set tabstop=2
set expandtab
set numberwidth=3
colorscheme darkblue
"}}}
" Mappings {{{
inoremap jk <Esc>
vnoremap jk <Esc>
nnoremap H 0
nnoremap L $

let mapleader = ";"

nnoremap <silent> <leader>tcd :tcd "%:h"<CR>
nnoremap <silent> <leader>wcd :lcd "%:h"<CR>
nnoremap <silent> <Tab> gt
nnoremap <silent> <S-Tab> gT

nnoremap <silent> <leader>ev :vsplit $HOME/.vimrc<CR>
nnoremap <silent> <leader>sv :source $HOME/.vimrc<CR>

nnoremap <silent> <leader>bw :bwipeout<CR>

function! ResetHLSearch()
  let &hlsearch=!&hlsearch
endfunction

nnoremap <expr> <leader>hc ResetHLSearch()
"}}}
"functions{{{
if has("autocmd") && exists("+omnifunc")
  autocmd Filetype *
    \	if &omnifunc == "" |
    \		setlocal omnifunc=syntaxcomplete#Complete |
    \	endif
endif
"}}}
"vim plug{{{
call plug#begin('~/.vim/plugged/')
  Plug 'ycm-core/YouCompleteMe', { 'frozen': 1 }
  Plug 'SirVer/ultisnips' | Plug 'honza/vim-snippets'
  Plug 'junegunn/fzf', { 'dir': '/usr/share/vim/vimfiles/plugin/fzf.vim', 'do': './install --all' }
  Plug 'tpope/vim-fugitive'
  Plug 'tpope/vim-surround'
  Plug 'tpope/vim-commentary'
  Plug 'tpope/vim-unimpaired'
call plug#end()
"}}}
"Plugin configuration{{{
"}}}
