"~/.vim/after/ftplugin/python.vim
"commands to be executed after vim's filetype stuff

function! SetPythonOptions()
    setlocal formatoptions-=o formatoptions-=r
    setlocal omnifunc=pythoncomplete#Complete
    let b:filetype_extension="py"

    let g:pylint_onwrite = 0

    "let python_highlight_all=2
    "syntax keyword pythonReturn return
    hi link pythonOperator Statement

    compiler pylint
endfunction

call SetPythonOptions()
