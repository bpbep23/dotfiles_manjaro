let g:ale_c_cc_options='-std=gnu11 -Wall -Iinclude'
let g:ale_c_cc_executable='gcc'
let b:ale_linters = ['cc', 'flawfinder', 'ccls', 'cppcheck']
let b:ale_fixers = ['clang-format', 'uncrustify']
let b:ale_c_parse_makefile=1

setlocal foldmethod=syntax
let c_comment_strings = 1
let c_gnu = 1
let c_syntax_for_h = 1

setlocal fo=croq
setlocal comments=s1:/*,mb:*,ex:*/

setlocal makeprg=gcc\ -Wall\ -Wextra\ -std=gnu99\ -Iinclude\ %\ $*

" command -nargs=* CFileCompile :make CCompileDispatcher<f-args>

