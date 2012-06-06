"=============================================================================
" File:        generalFunctions.vim
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

function! RenameFile()
    let old_name = expand('%')
    let new_name = input('New file name ('.old_name.'): ')
    if new_name != '' && new_name != old_name
        exec ':saveas ' . new_name
        exec ':silent !rm ' . old_name
        redraw!
    endif
endfunction

"because tagbar and minubufexplorer can be *really* annoying together
function! ToggleOggleOoo()
    TagbarToggle
    let buf = bufname("%")
    if buf == "-MiniBufExplorer-"
        wincmd j
    elseif buf == "__Tagbar__"
        wincmd h| wincmd j| wincmd l| wincmd l
        TagbarSetFoldlevel 1
        exe 'norm! 2j'
    endif
endfunction
