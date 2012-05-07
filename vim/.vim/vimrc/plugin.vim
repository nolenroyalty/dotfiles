"always show minibuffexplorer
let g:miniBufExplorerMoreThanOne=1

"takes care of how autocomplete menus should appear and disappear
autocmd CursorMovedI * if pumvisible() == 0|pclose|endif
autocmd InsertLeave * if pumvisible() == 0|pclose|endif

"sometimes it's annoying but I love tagbar when I want it
let g:tagbar_compact = 1
"autocmd VimEnter * nested :call tagbar#autoopen()
