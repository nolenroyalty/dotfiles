"~/.vim/after/ftplugin/perl.vim
"commands to be executed after vim's filetype stuff

setlocal formatoptions-=o formatoptions-=r
setlocal omnifunc=perlcomplete#OmniPerl_Complete
"au BufNewFile *.pl s-^-#!/usr/bin/perl\r\ruse strict;\ruse warnings;\r\r-|normal 
