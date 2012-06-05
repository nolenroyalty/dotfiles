"=============================================================================
" File:        checkMapping.vim
" Author:      Nolen Royalty (nolen.royalty@gmail.com)
" Version:     1.0
"=============================================================================

function! CheckMapping()
    let keysequence = substitute(input("Key sequence: "), ';', '<Leader>', 'g')
    if empty(mapcheck(keysequence))
        let mapstring = "Map ".keysequence." to: "
        let targetmapping = substitute(input(mapstring), ';', '<Leader>', 'g')
        normal omap =keysequence 
        normal A=targetmapping
    else
        TagbarClose
        TagbarOpen
        10 wincmd h
        10 wincmd j
        TagbarClose
        TagbarOpen
        normal zR
        let searchstring = '^\s\+\C'.keysequence
        silent call search(searchstring, 'wc')
    endif
endfunction
