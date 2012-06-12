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

function! KillAboveLine()
    normal kdd
endfunction

function! KillBelowLine()
    normal jddk
endfunction

function! SwapWithAboveLine()
    normal ddkP
endfunction

function! SwapWithBelowLine()
    normal ddp
endfunction

function! AddEmptyLineAbove()
    normal m`O``
endfunction

function! AddEmptyLineBelow()
    normal m`o``
endfunction
