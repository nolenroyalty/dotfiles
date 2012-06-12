"~/.vim/ftplugin/perl/perl.vim

"au BufEnter *.pl execute ":silent! s-^$-#!/usr/bin/perl\r\ruse strict;\ruse warnings;\r\r-|normal "
au BufNewFile *.pl execute ":silent! s-^$-#!/usr/bin/perl\r\ruse strict;\ruse warnings;\r\r-|normal "
