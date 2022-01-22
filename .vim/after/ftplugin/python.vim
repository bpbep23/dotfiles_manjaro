setlocal omnifunc=ale#completion#OmniFunc

setlocal shiftwidth=4

let python_no_number_highlight=0
let python_no_builtin_highlight=0
let python_no_exception_highlight = 0
let python_no_doctest_highlight = 0
let python_no_doctest_code_highlight = 0
let python_space_error_highlight = 0

let b:ale_linters = ['pyright', 'pylint', 'yapf', 'black']
