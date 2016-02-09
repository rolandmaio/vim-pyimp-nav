" Vim File Type Plugin for navigating Python module imports.
" Last Change: February 9, 2016
" Maintainer: Roland Maio <rolandmaio38@gmail.com>

if exists("g:loaded_imp_nav")
    finish
endif
let g:loaded_imp_nav = 1

let s:save_cpo = &cpo
set cpo&vim

map <unique> <Leader>gf <Plug>imp_nav_goto
noremap <unique> <script> <Plug>imp_nav_goto <SID>openFile
noremap <SID>openFile :call <SID>openFile()<CR>
"noremap <SID>Add  :call <SID>Add(expand("<cword>"), 1)<CR>

function s:openFile()
python << EOF
import vim
source_line = vim.eval("getline('.')")
print source_line
EOF
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
