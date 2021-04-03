set runtimepath^=~/.vim runtimepath+=~/.vim/after
let &packpath = &runtimepath
source ~/.vimrc

" function! ConfigStatusLine()
"   lua require('plugins.status-line')
" endfunction

" augroup status_line_init
"   autocmd!
"   autocmd VimEnter * call ConfigStatusLine()
" augroup END

" NOTE: this app sucks and so does the plugin

" function! TwfExit(path)
"   function! TwfExitClosure(job_id, data, event) closure
"     bd!
"     try
"       let out = filereadable(a:path) ? readfile(a:path) : []
"     finally
"       silent! call delete(a:path)
"     endtry
"     if !empty(out)
"       execute 'edit! ' . out[0]
"     endif
"   endfunction
"   return funcref('TwfExitClosure')
" endfunction

" function! Twf()
"   let temp = tempname()
"   call termopen('twf ' . @% . ' > ' . temp, { 'on_exit': TwfExit(temp) })
"   startinsert
" endfunction

" nnoremap <silent> ;twf :call Twf()<CR>
