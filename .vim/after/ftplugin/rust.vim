let b:ale_disable_lsp=1
setlocal foldmethod=syntax
setlocal shiftwidth=4
setlocal tabstop=4
setlocal formatoptions-=o
setlocal formatoptions-=r
setlocal tags=$HOME/code/lab/rust/**/.tags
setlocal tags+=$HOME/code/lab/rust/.tags;


let b:ale_fixers = ['rustfmt', 'remove_trailing_lines', 'trim_whitespace']
let g:rust_fold=1
