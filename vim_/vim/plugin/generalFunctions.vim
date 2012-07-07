"=============================================================================
" File:        generalFunctions.vim
" Author:      Nolen Royalty (nolen.royalty@gmail.com)
" Version:     1.0
"=============================================================================

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

function! GetTempName(...)
    let extension = a:0 >= 1 ? a:1 : "tmp" 
    let code_dir = readfile(expand("$HOME")."/.dotfiles_config", '', 1)[0][8:]."/tmp/"
    return code_dir.strftime("%m-%d-%Y.%T")."-tmpfile.".extension
endfunction

function! TempFile()
    let tempname = GetTempName(b:filetype_extension)
    let path_input = input("Enter filename or write to '".tempname."': ")
    let path = empty(path_input) ? tempname : path_input
    exe "write ".path
    echo "Wrote file to ".path
endfunction

function! OpenTempFile()
    exe "edit ".GetTempName()
endfunction

