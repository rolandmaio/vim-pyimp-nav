" Vim File Type Plugin for navigating Python module imports.
" Last Change: May 25, 2016
" Maintainer: Roland Maio <rolandmaio38@gmail.com>

if !has("python")
    echo "This Vim instance does not support Python 2."
    echo "Aborting loading Python Import Navigation plugin."
    finish
endif

if !exists(":PINGo")
    command -nargs=0 PINGo :call <SID>openFile()
else
    echo "PINGo command is already mapped."
    echo "Aborting loading Python Import Navigation plugin."
    finish
endif

if exists("g:loaded_pin")
    finish
endif
let g:loaded_pin = 1

let s:save_cpo = &cpo
set cpo&vim

let s:path = fnamemodify(resolve(expand('<sfile>:p')), ':h') . '/pin.py'

function s:openFile()
    execute 'pyfile ' . s:path
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
