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
        TagbarToggle
        TagbarToggle
        normal gg
        wincmd h
        wincmd K
        wincmd j
        10 wincmd l
        TagbarSetFoldlevel(10)
    endif
endfunction

function! UnfuckMinibufexplrWincmdh()
    wincmd h
    if bufname("%") == "-MiniBufExplorer-"
        wincmd j
    endif
endfunction

function! UnfuckMinibufexplrWinclose()
    wincmd q
    if bufname("%") == "-MiniBufExplorer-"
        wincmd j
    endif
endfunction

function! TempFile()
    let tempname = strftime("%m-%d-%Y.%T")."-tmpfile.".b:filetype_extension

    "dotfiles config's first line contains the location of CODEDIR, so we cut
    "off the CODEDIR= part to just get the location of the dir
    let code_dir = readfile(expand("$HOME")."/.dotfiles_config", '', 1)[0][8:]."/tmp/"
    let path = code_dir.tempname
    let path_input = input("Enter filename or write to '".path."': ")
    if empty(path_input)
        let path = path
    else
        let path = code_dir.path_input
    endif
    exe "write ".path
    echo "Wrote file to ".path
endfunction
