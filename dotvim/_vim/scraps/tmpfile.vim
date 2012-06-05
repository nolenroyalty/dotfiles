"Generate filename for datetime, add extension if possible, write to
"codedir/tmp if it exists
function! GenerateTmpFilename()
    let ftypedict = {"python": "py", "vim": "vim", "perl": "pl", "sh": "sh", "zsh": "zsh"}
    return strftime("%m-%d-%y__%H:%M:%S").".".get(ftypedict, &filetype, "tmp")
endfunction

map <Leader><C-w> :r ~/.dotfiles_config<Cr>0df=v$d:w <C-r>"/tmp/<C-r>=GenerateTmpFilename()<Cr><Cr>

