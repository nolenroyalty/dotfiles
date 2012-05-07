"For when vim is opened via an alias
au BufRead vv set syntax=vim

"For some reason html doesn't indent the way it should?
au FileType html,xhtml set autoindent

"python stuff
au FileType python syntax keyword pythonReturn return
au FileType python hi pythonTodo ctermfg=red
au BufEnter python let g:pymode_lint_onfly = 1
au BufEnter python let g:pymode_lint_write = 0
au FileType python let python_highlight_all = 1
let g:pydiction_location = '/Users/scale/.vim/vimfiles/ftplugin/pydiction/complete-dict'
"testing 1 2 3
autocmd FileType python set omnifunc=pythoncomplete#Complete
autocmd FileType javascript set omnifunc=javascriptcomplete#CompleteJS
autocmd FileType html set omnifunc=htmlcomplete#CompleteTags
autocmd FileType css set omnifunc=csscomplete#CompleteCSS
autocmd FileType xml set omnifunc=xmlcomplete#CompleteTags
autocmd FileType php set omnifunc=phpcomplete#CompletePHP
autocmd FileType c set omnifunc=ccomplete#Complete
autocmd FileType pl set omnifunc=perlcomplete#OmniPerl_Complete
