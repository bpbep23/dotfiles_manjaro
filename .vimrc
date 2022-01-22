" vim: foldmethod=marker
" vimrc
"General configration
filetype plugin indent on
syntax on

set termguicolors
set ignorecase
set clipboard=unnamedplus
" set hlsearch
set laststatus=0
set showtabline=0
set shiftwidth=2
set tabstop=2
set expandtab
set numberwidth=3
set nonumber
set formatoptions-=o
set formatoptions-=r
set smartcase
set magic
set incsearch

" Do we want nosplit? New feature, try it out
" set inccommand=nosplit
set inccommand=nosplit

set grepprg=rg\ --vimgrep
set autowrite
set previewheight=5
set signcolumn=number
set tags+=./.tags
set tags+=$HOME/code/tags
set tags+=$HOME/code/.tags

augroup vimrc-incsearch-highlight
  autocmd!
  autocmd CmdlineEnter /,\? :set hlsearch
  autocmd CmdlineLeave /,\? :set nohlsearch
augroup END

let c_comment_strings = 1
let c_gnu = 1
let c_syntax_for_h = 1

" Mappings 
inoremap jk <Esc>
vnoremap jk <Esc>
nnoremap H ^
nnoremap L $

let mapleader = ';'

nnoremap <silent> <leader>tcd :tchdir %:h<CR>
nnoremap <silent> <leader>wcd :lcd %:h<CR>
nnoremap <silent> <Tab> gt
nnoremap <silent> <S-Tab> gT

nnoremap <silent> <leader>ev :vsplit $HOME/.vimrc<CR>
nnoremap <silent> <leader>sv :source $MYVIMRC<CR>

nnoremap <silent> <leader>bw :bwipeout!<CR>

function! ResetHLSearch()
  let &hlsearch=!&hlsearch
endfunction

nnoremap <expr> <leader>hc ResetHLSearch()

cnoremap <C-A> <Home>
cnoremap <C-F> <Right>
cnoremap <C-B> <Left>
cnoremap <C-K> <End><C-U>

tnoremap <Esc> <C-\><C-n>
tnoremap jk    <C-\><C-n>
tnoremap <C-W><C-h> <C-\><C-N><C-w>h
tnoremap <C-W><C-j> <C-\><C-N><C-w>j
tnoremap <C-W><C-k> <C-\><C-N><C-w>k
tnoremap <C-W><C-l> <C-\><C-N><C-w>l


"functions
if has('autocmd') && exists('+omnifunc')
  autocmd Filetype *
    \	if &omnifunc == "" |
    \		setlocal omnifunc=syntaxcomplete#Complete |
    \	endif
endif


function! Syn()
  for id in synstack(line("."), col("."))
    echo synIDattr(id, "name")
  endfor
endfunction
command! -nargs=0 Hlg call Syn()

"tabline 
function MyTabLine()
  let s = ''
  for i in range(tabpagenr('$'))
    " select the highlighting
    if i + 1 == tabpagenr()
      let s .= '%#TabLineSel#'
    else
      let s .= '%#TabLine#'
    endif

    " set the tab page number (for mouse clicks)
    let s .= '%' . (i + 1) . 'T'

    " the label is made by MyTabLabel()
    let s .= ' %{MyTabLabel(' . (i + 1) . ')} '
  endfor

  " after the last tab fill with TabLineFill and reset tab page nr
  let s .= '%#TabLineFill#%T'

  " right-align the label to close the current tab page
  if tabpagenr('$') > 1
    let s .= '%=%#TabLine#%999Xclose'
  endif

  return s
endfunction

function MyTabLabel(n)
  let buflist = tabpagebuflist(a:n)
  let winnr = tabpagewinnr(a:n)
  let bufname = bufname(buflist[winnr - 1])
  return fnamemodify(bufname, ':t')
endfunction

set tabline=%!MyTabLine()

set laststatus=0

" unfucking the preview window
function! CleanupPreviewWindow()
  if &previewwindow 
    setlocal statusline=[Preview][RO]
    setlocal nonumber
    setlocal signcolumn=no
    call PreviewWindowFTDispatcher()
  endif
endfunction

" setting ft on preview window based on source lang
fun PreviewWindowFTDispatcher()
  let originating_buf_ft = expand('#:e')
  if originating_buf_ft ==? 'rs'
    setlocal syntax=markdown 
  elseif originating_buf_ft ==? 'py' 
    setlocal syntax=rst 
  endif
endf

augroup PreviewWindowShit
  autocmd WinEnter * call CleanupPreviewWindow()
augroup END

fun GetSyntaxInfoUnderCursor()
  echo synIDattr(synID(line("."), col("."), 1), "name")
endf

command! -bang SynItemInfo call GetSyntaxInfoUnderCursor()

command! -nargs=* -bang RG call RipgrepFzf(<q-args>, <bang>0)

"vim plug
call plug#begin('~/.vim/plugged/')
  Plug 'ycm-core/YouCompleteMe', { 'frozen': 1 }
  Plug 'dense-analysis/ale'
  Plug 'SirVer/ultisnips' | Plug 'honza/vim-snippets'
  Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
  Plug 'junegunn/fzf.vim'
  Plug 'tpope/vim-fugitive'
  Plug 'tpope/vim-surround'
  Plug 'tpope/vim-commentary'
  Plug 'tpope/vim-unimpaired'
  Plug 'rhysd/clever-f.vim'
  Plug 'jiangmiao/auto-pairs'
  Plug 'wellle/targets.vim'
  Plug 'jeetsukumaran/vim-pythonsense'
  " Plug 'romainl/vim-qf'
  Plug 'Valloric/ListToggle'
  if has('nvim')
    Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'} 
  end

  Plug 'rafi/awesome-vim-colorschemes'
  Plug 'sainnhe/edge'
  Plug 'humanoid-colors/vim-humanoid-colorscheme'
  Plug 'kyazdani42/nvim-web-devicons'
  Plug 'ryanoasis/vim-devicons'
  Plug 'nvim-lualine/lualine.nvim'
  " Plug 'vimpostor/vim-tpipeline'
  Plug 'wincent/ferret'
  Plug 'neovimhaskell/haskell-vim'
  Plug 'cespare/vim-toml'
  Plug 'rust-lang/rust.vim'
  Plug 'marshallward/vim-restructuredtext'
  " Plug 'gabrielelana/vim-markdown'
  " Plug 'tpope/vim-markdown'
  Plug 'elzr/vim-json'
  Plug 'godlygeek/tabular'
  Plug 'plasticboy/vim-markdown'
  Plug 'chrisbra/csv.vim'
  Plug 'preservim/tagbar'
  " Plug 'ms-jpq/chadtree', {'branch': 'chad', 'do': 'python3 -m chadtree deps'}
  Plug 'wadackel/vim-dogrun'
  Plug 'cormacrelf/vim-colors-github'
  Plug 'glepnir/zephyr-nvim'
  Plug 'Rigellute/rigel'
  Plug 'haishanh/night-owl.vim'
  Plug 'azadkuh/vim-cmus'
  Plug 'vim-python/python-syntax'
  Plug 'tmhedberg/SimpylFold'
  Plug 'Konfekt/FastFold'
  Plug 'chrisbra/NrrwRgn'
  Plug 'francoiscabrol/ranger.vim'
  Plug 'rbgrouleff/bclose.vim'
  Plug 'voldikss/vim-floaterm'
  Plug 'pangloss/vim-javascript'
  Plug 'HerringtonDarkholme/yats.vim'
  Plug 'MaxMEllon/vim-jsx-pretty'
  Plug 'machakann/vim-highlightedyank'
  Plug 'beloglazov/vim-online-thesaurus'
  Plug 'voldikss/fzf-floaterm'
  Plug 'windwp/vim-floaterm-repl'

  Plug 'udalov/kotlin-vim'

  Plug 'KeitaNakamura/neodark.vim'
  Plug 'sainnhe/edge'
call plug#end()

"Plugin configuration
"fzf
let g:fzf_command_prefix = 'Z'

augroup fzf
  autocmd!
augroup END

function! RipgrepFzf(query, fullscreen)
  let command_fmt = 'rg --column --line-number --no-heading --color=always --smart-case -- %s || true'
  let initial_command = printf(command_fmt, shellescape(a:query))
  let reload_command = printf(command_fmt, '{q}')
  let spec = {'options': ['--phony', '--query', a:query, '--bind', 'change:reload:'.reload_command]}
  call fzf#vim#grep(initial_command, 1, fzf#vim#with_preview(spec), a:fullscreen)
endfunction

command! -nargs=* -bang RG call RipgrepFzf(<q-args>, <bang>0)

" An action can be a reference to a function that processes selected lines
function! s:build_quickfix_list(lines)
  call setqflist(map(copy(a:lines), '{ "filename": v:val }'))
  copen
  cc
endfunction

let g:fzf_action = {
  \ 'ctrl-q': function('s:build_quickfix_list'),
  \ 'ctrl-t': 'tab split',
  \ 'ctrl-x': 'split',
  \ 'ctrl-v': 'vsplit' }

command! -bang -complete=dir -nargs=* LS
    \ call fzf#run(fzf#wrap({'source': 'ls', 'dir': <q-args>}, <bang>0))

nnoremap <silent><leader>fzs :ZSnippets<CR>
nnoremap <silent><leader>fzm :ZMaps<CR>
nnoremap <silent><leader>fzM :ZMarks<CR>
nnoremap <silent><leader>fzb :ZBuffers<CR>
nnoremap <silent><leader>fzw :ZWindows<CR>
nnoremap <silent><leader>fzr :ZRg<CR>
nnoremap <silent><leader>fzg :ZAg<CR>
nnoremap <silent><leader>fzf :ZFiles<CR>
nnoremap <silent><leader>FZ :Z<CR>

command! -bang FzfArgs call fzf#run(fzf#wrap('args',
    \ {'source': map([argidx()]+(argidx()==0?[]:range(argc())[0:argidx()-1])+range(argc())[argidx()+1:], 'argv(v:val)')}, <bang>0))

nnoremap <silent><leader>fza :FzfArgs<CR>

function! s:fzf_neighbouring_files()
  let current_file =expand('%')
  let cwd = fnamemodify(current_file, ':p:h')
  let command = 'ag -g "" -f ' . cwd . ' --depth 0'

  call fzf#run({
        \ 'source': command,
        \ 'sink':   'e',
        \ 'options': '-m -x +s',
        \ 'window':  'enew' })
endfunction

command! FzfNeighbors call s:fzf_neighbouring_files()

"" --column: Show column number
" --line-number: Show line number
" --no-heading: Do not show file headings in results
" --fixed-strings: Search term as a literal string
" --ignore-case: Case insensitive search
" --no-ignore: Do not respect .gitignore, etc...
" --hidden: Search hidden files and folders
" --follow: Follow symlinks -glob: Additional conditions for search (in this case ignore everything in the .git/ folder)

" ripgrep command to search in multiple files
autocmd fzf VimEnter * command! -nargs=* Rg
  \ call fzf#vim#grep(
  \   'rg --column --line-number --no-heading --fixed-strings --ignore-case --no-ignore --hidden --follow --glob "!.git/*" --color "always" '.shellescape(<q-args>), 1,
  \   <bang>0 ? fzf#vim#with_preview('up:60%')
  \           : fzf#vim#with_preview('right:50%:hidden', '?'),
  \   <bang>0)

" ripgrep - ignore the files defined in ignore files (.gitignore...)
autocmd fzf VimEnter * command! -nargs=* Rgi
  \ call fzf#vim#grep(
  \   'rg --column --line-number --no-heading --fixed-strings --ignore-case --hidden --follow --glob "!.git/*" --color "always" '.shellescape(<q-args>), 1,
  \   <bang>0 ? fzf#vim#with_preview('up:60%')
  \           : fzf#vim#with_preview('right:50%:hidden', '?'),
  \   <bang>0)

" ripgrep - ignore the files defined in ignore files (.gitignore...) and doesn't ignore case
autocmd fzf VimEnter * command! -nargs=* Rgic
  \ call fzf#vim#grep(
  \   'rg --column --line-number --no-heading --fixed-strings --hidden --follow --glob "!.git/*" --color "always" '.shellescape(<q-args>), 1,
  \   <bang>0 ? fzf#vim#with_preview('up:60%')
  \           : fzf#vim#with_preview('right:50%:hidden', '?'),
  \   <bang>0)

" ripgrep - ignore the files defined in ignore files (.gitignore...) and doesn't ignore case
autocmd fzf VimEnter * command! -nargs=* Rgir
  \ call fzf#vim#grep(
  \   'rg --column --line-number --no-heading --hidden --follow --glob "!.git/*" --color "always" '.shellescape(<q-args>), 1,
  \   <bang>0 ? fzf#vim#with_preview('up:60%')
  \           : fzf#vim#with_preview('right:50%:hidden', '?'),
  \   <bang>0)

" ripgrep - ignore the files defined in ignore files (.gitignore...) and doesn't ignore case and activate regex search
autocmd fzf VimEnter * command! -nargs=* Rgr
  \ call fzf#vim#grep(
  \   'rg --column --line-number --no-heading --hidden --no-ignore --follow --glob "!.git/*" --color "always" '.shellescape(<q-args>), 1,
  \   <bang>0 ? fzf#vim#with_preview('up:60%')
  \           : fzf#vim#with_preview('right:50%:hidden', '?'),
  \   <bang>0)

let g:fzf_colors =
\ { 'fg':      ['fg', 'Normal'],
  \ 'bg':      ['bg', 'Normal'],
  \ 'hl':      ['fg', 'Comment'],
  \ 'fg+':     ['fg', 'CursorLine', 'CursorColumn', 'Normal'],
  \ 'bg+':     ['bg', 'CursorLine', 'CursorColumn'],
  \ 'hl+':     ['fg', 'Statement'],
  \ 'info':    ['fg', 'PreProc'],
  \ 'border':  ['fg', 'Ignore'],
  \ 'prompt':  ['fg', 'Conditional', 'Comment'],
  \ 'pointer': ['fg', 'Exception'],
  \ 'marker':  ['fg', 'Keyword'],
  \ 'spinner': ['fg', 'Label'],
  \ 'header':  ['fg', 'Comment'] }
 
" anchor to bottom vs default?
let g:fzf_layout = { 'window': { 'width': 0.91, 'height': 0.55, 'relative': v:false, 'yoffset': 1.0 } }

" if has('nvim') && !exists('g:fzf_layout')
"   autocmd! FileType fzf
"   autocmd  FileType fzf set laststatus=0 noshowmode noruler
"     \| autocmd BufLeave <buffer> set laststatus=2 showmode ruler
" endif
" autocmd! FileType fzf set laststatus=0 noshowmode noruler
"   \| autocmd BufLeave <buffer> set laststatus=0 showmode ruler

"ultisnips
let g:UltiSnipsExpandTrigger='<c-e>'
let g:UltiSnipsJumpForwardTrigger='<c-f>'
let g:UltiSnipsJumpBackwardTrigger='<c-b>'

let g:ultisnips_python_style='sphinx'

"ycm 
let g:ycm_language_server = []
let g:ycm_language_server += [
  \   {
  \     'name': 'haskell-language-server',
  \     'cmdline': [ 'haskell-language-server-wrapper', '--lsp' ],
  \     'filetypes': [ 'haskell', 'lhaskell' ],
  \     'project_root_files': [ 'stack.yaml', 'cabal.project', 'package.yaml', 'hie.yaml' ],
  \   },
  \ ]

let g:ycm_seed_identifiers_with_syntax=1
let g:ycm_use_ultisnips_completer=1
let g:ycm_cache_omnifunc = 0
let g:ycm_goto_buffer_command='split-or-existing-window'
let g:ycm_clangd_uses_ycmd_caching = 0
let g:ycm_clangd_binary_path = exepath('clangd')
let g:ycm_open_loclist_on_ycm_diags=0
let g:ycm_extra_conf_globlist = ['~/code/projects/*', '~/code/lab/c/*','!~/*']
let g:ycm_enable_diagnostic_highlighting=0
let g:ycm_enable_diagnostic_signs=0
let g:ycm_show_diagnostics_ui=0
let g:ycm_key_detailed_diagnostics = '<leader>yv'

nnoremap <silent> <leader>yt :YcmCompleter GetType<CR>
nnoremap <silent> <leader>K :YcmCompleter GetDoc<CR>
nnoremap <silent> <leader>yd :YcmCompleter GoToDefinition<CR>
nnoremap <silent> <leader>yD :YcmCompleter GoToDeclaration<CR>
nnoremap <silent> <leader>ys :YcmCompleter GoToSymbol<CR>
nnoremap <silent> <leader>yr :YcmCompleter GoToReferences<CR>
nnoremap <silent> <leader>yl :YcmDiags<CR>


"ale
inoremap <silent> <C-x><C-A> <C-\><C-O>:ALEComplete<CR>
nnoremap <silent> <leader>al :ALELint<CR>
nnoremap <silent> <leader>ah :ALEHover<CR>
nnoremap <silent> <leader>af :ALEFix<CR>
nnoremap <silent> <leader>a] :ALENextWrap<CR>
nnoremap <silent> <leader>a[ :ALEPreviousWrap<CR>
nnoremap <silent> <leader>av :ALEDetail<CR>


let g:ale_lint_on_save = 0
let g:ale_sh_language_server_use_global = 1
let g:ale_set_loclist = 0
let g:ale_set_quickfix = 1
let g:ale_set_signs=1
let g:ale_set_highlights=0
let g:ale_lint_on_enter = 0
let g:ale_lint_on_filetype_changed = 0
let g:ale_lint_on_insert_leave = 0
let g:ale_lint_on_save = 0
let g:ale_lint_on_text_changed = 0
let g:ale_sign_highlight_linenrs=1
let g:ale_sign_error=' ✗'
let g:ale_sign_info=' ¡'
let g:ale_sign_warning=' ?'
let g:ale_detail_to_floating_preview=1
let g:ale_floating_preview=1
let g:ale_hover_to_floating_preview=1
" let g:ale_floating_window_border=['│', '─', '╭', '╮', '╯', '╰']
let g:ale_floating_window_border=[]
" let g:ale_linters_explicit = 1

let g:ale_completion_symbols = {
      \ 'text': '',
      \ 'method': '',
      \ 'function': '',
      \ 'constructor': '',
      \ 'field': '',
      \ 'variable': '',
      \ 'class': '',
      \ 'interface': '',
      \ 'module': '',
      \ 'property': '',
      \ 'unit': 'unit',
      \ 'value': 'val',
      \ 'enum': '',
      \ 'keyword': 'keyword',
      \ 'snippet': '',
      \ 'color': 'color',
      \ 'file': '',
      \ 'reference': 'ref',
      \ 'folder': '',
      \ 'enum member': '',
      \ 'constant': '',
      \ 'struct': '',
      \ 'event': 'event',
      \ 'operator': '',
      \ 'type_parameter': 'type param',
      \ '<default>': 'v'
      \ }

let g:ale_fixers = {
\   'javascript': ['prettier'],
\   'css': ['prettier'],
\}

" tpipeline
" set stl=%!tpipeline#stl#line()
" let g:tpipeline_statusline = '%f'
" let g:tpipeline_split = 1

" ferret
let g:FerretMap = 0
let g:FerretQFMap=1
nnoremap <leader>fa <Plug>(FerretAck)
nnoremap <leader>fw :Ack <C-R><C-W><CR>
nnoremap <leader>fl <Plug>(FerretLack)
nnoremap <leader>fb :Back <C-R><C-W><CR>
nnoremap <leader>fq <Plug>(FerretQuack)


" colorscheme opts
let g:materialbox_bold=1
let g:materialbox_italic=1
let g:materialbox_contrast_dark=1
let g:materialbox_improved_warnings=1
let g:materialbox_undercurl=1
let g:materialbox_improved_strings=0

" vim-markdown
let g:vim_markdown_math=1
let g:vim_markdown_new_list_item_indent = 2
let g:vim_markdown_no_default_key_mappings = 0
let g:vim_markdown_toc_autofit = 1
let g:vim_markdown_follow_anchor = 1
let g:vim_markdown_anchorexpr = "'<<'.v:anchor.'>>'"
let g:vim_markdown_frontmatter = 1
let g:vim_markdown_json_frontmatter = 1
let g:vim_markdown_strikethrough = 1
let g:vim_markdown_no_extensions_in_markdown = 1
let g:vim_markdown_edit_url_in = 'tab'

"tagbar
nnoremap <silent> <leader>tb :TagbarToggle<CR>
let g:tagbar_width=30

" colorfag shit
let g:github_colors_soft = 1

let g:PaperColor_Theme_Options = {
  \   'language': {
  \     'python': {
  \       'highlight_builtins' : 1
  \     },
  \     'cpp': {
  \       'highlight_standard_library': 1
  \     },
  \     'c': {
  \       'highlight_builtins' : 1
  \     }
  \   },
  \   'theme': {
  \     'default': {
  \       'allow_bold': 1,
  \       'alow_italic': 1,
  \     }
  \   }
  \ }

" py syntax
let g:python_highlight_all = 1
let g:python_highlight_indent_errors = 0
let g:python_highlight_space_errors = 0

" py folding
let g:SimpylFold_docstring_preview = 1

let g:markdown_folding = 1
let g:tex_fold_enabled = 1
let g:vimsyn_folding = 'af'
let g:xml_syntax_folding = 1
let g:javascript_fold = 1
let g:sh_fold_enabled= 7
let g:ruby_fold = 1
let g:perl_fold = 1
let g:perl_fold_blocks = 1
let g:r_syntax_folding = 1
let g:rust_fold = 1
let g:php_folding = 1

let g:fastfold_savehook = 0

let g:ranger_replace_netrw = 1
let g:ranger_map_keys = 0
map <leader>R :Ranger<CR>

let g:online_thesaurus_map_keys = 0

let g:ale_html_prettier_options='--no-config --parser=html'
" let g:ale_html_tidy_options='-i 2'

let hs_highlight_boolean = 1
let hs_highlight_delimiters = 1
let hs_highlight_more_types = 1
let hs_highlight_types = 1
let g:haskell_enable_quantification = 1   " to enable highlighting of `forall`
let g:haskell_enable_recursivedo = 1      " to enable highlighting of `mdo` and `rec`
let g:haskell_enable_arrowsyntax = 1      " to enable highlighting of `proc`
let g:haskell_enable_pattern_synonyms = 1 " to enable highlighting of `pattern`
let g:haskell_enable_typeroles = 1        " to enable highlighting of type roles
let g:haskell_enable_static_pointers = 1  " to enable highlighting of `static`
let g:haskell_backpack = 1                " to enable highlighting of backpack keywords
let g:haskell_indent_if = 3
let g:haskell_indent_case = 2
let g:haskell_indent_let = 4
let g:haskell_indent_where = 6
let g:haskell_indent_before_where = 2
let g:haskell_indent_after_bare_where = 2
let g:haskell_indent_do = 3
let g:haskell_indent_in = 1
let g:haskell_indent_guard = 2

let g:gruvbox_contrast_dark='hard'
let g:gruvbox_bold=0
let g:gruvbox_improved_strings=1
let g:gruvbox_improved_warnings=1 

let g:sonokai_better_performance=1

let g:materialbox_contrast_dark='high'
let g:materialbox_improved_strings=1
let g:onedark_terminal_italics=1
let g:deus_contrast_dark='high'
let g:deus_contrast_light='high'
let g:deus_italic=1


nnoremap <silent> ;FN :FloatermNew<CR>
tnoremap <silent> ;FN <C-\><C-n>:FloatermNew<CR>
nnoremap <silent> ;F[ :FloatermPrev<CR>
tnoremap <silent> ;F[ <C-\><C-n>:FloatermPrev<CR>
nnoremap <silent> ;F] :FloatermNext<CR>
tnoremap <silent> ;F] <C-\><C-n>:FloatermNext<CR>
nnoremap <silent> ;FT :FloatermToggle<CR>
tnoremap <silent> ;F] <C-\><C-n>:FloatermToggle<CR>
" nnoremap <silent> :FloatermNew --wintype=split python
vnoremap <silent> ;FP :'<,'>FloatermNew --wintype=split ipython3
nnoremap <silent> ;FP :FloatermNew --wintype=split ipython3

command! FTZF FloatermNew fzf
command! FTRipgrep FloatermNew -width=0.8 --height=0.8 rg
command! FTRanger FloatermNew ranger
command! FTPython FloatermNew python3
command! FTIpython FloatermNew ipython3
command! FTNode FloatermNew node

"### COLORZZZZZZZ ###

syntax on

"" decent
" colorscheme edge
" colorscheme meta5
" colorscheme rakr
" colorscheme gruvbox
" colorscheme stellarized
" colorscheme purify
" colorscheme rigel
" colorscheme spacecamp_lite
" colorscheme stellarized
" colorscheme yellow-moon

"" a+
" colorscheme ayu
" colorscheme deus
" colorscheme sonokai
" colorscheme PaperColor
" colorscheme materialbox
" colorscheme molokai
" colorscheme molokayo
" colorscheme sonokai
" colorscheme one
" colorscheme termschool
" colorscheme oceanic_material
" colorscheme onedark
" colorscheme oceanic_material

let g:oceanic_next_terminal_bold=1
let g:oceanic_next_terminal_italic=1
" colorscheme OceanicNext

let g:neodark#italics=1
let g:neodark#terminal_transparent=1
let g:neodark#solid_vertsplit=1
" colorscheme neodark

let g:onedark_hide_endofbuffer=1
let g:onedark_terminal_italics=1

let g:edge_better_performance=1
let g:edge_current_word='grey background'
let g:edge_diagnostic_virtual_text='colored'
let g:edge_diagnostic_line_highlight=1
let g:edge_diagnostic_text_highlight=1
" can be blue, green or purple
let g:edge_menu_selection_background = 'purple'
" TODO: play with this and see whacha like
let g:edge_transparent_background = 0
" let g:edge_style='aura'
let g:edge_style='neon'
let g:edge_enable_italic=0
let g:edge_disable_italic_comment=0

" colorscheme onedark
colorscheme edge

" ### END COLORFUL RICEFAGGOTRY ###

function! MyBlankUp() abort
  let cmd = 'put!=repeat(nr2char(10), v:count1)|silent +'
  return cmd
endfunction

function! MyBlankDown() abort
  let cmd = 'put =repeat(nr2char(10), v:count1)|silent -'
  return cmd
endfunction

" function MySTL()
"     if has("statusline")
"         hi User1 term=standout ctermfg=0 ctermbg=11 guifg=Black guibg=Yellow
"         let stl = ...
"         if exists("*CSV_WCol")
"             let csv = '%1*%{&ft=~"csv" ? CSV_WCol() : ""}%*'
"         else
"             let csv = ''
"         endif
"         return stl.csv
"     endif
" endfunc
" set stl=%!MySTL()

" NOTE: this method was recommended in 2017; think unnecessary?
execute "set t_8f=\e[38;2;%lu;%lu;%lum"
execute "set t_8b=\e[48;2;%lu;%lu;%lum"
