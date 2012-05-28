"~/.vim/after/ftplugin/python.vim
"commands to be executed after vim's filetype stuff

function! SetPythonOptions()
    setlocal formatoptions-=o formatoptions-=r
    setlocal omnifunc=pythoncomplete#Complete
    syntax keyword pythonReturn return
    hi pythonTodo ctermfg=red
    let python_highlight_all=2
endfunction

call SetPythonOptions()
"au Filetype python call SetPythonOptions()
