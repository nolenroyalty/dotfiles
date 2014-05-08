"=============================================================================
" File:        emacsKeys.vim
" Author:      Nolen Royalty (nolen.royalty@gmail.com)
" Version:     1.0
"=============================================================================
"emacs-style hotkeys for command line
cno <C-a> <Home>
cno <C-e> <End>
cno <C-b> <Left>
cno <C-f> <Right>
cno <C-n> <Down>
cno <C-p> <Up>
cno <C-d> <Del>
cno <C-k> <C-\>estrpart(getcmdline(), 0, getcmdpos()-1)<Cr>

"and a few for insert mode too
ino <C-a> <C-o>I
ino <C-e> <C-o>A
ino <C-f> <Right>
ino <C-b> <Left>
ino <C-d> <Del>
ino <C-k> <C-o>D

"use alt-f/b to jump between words in commandline/insert mode
cno f <C-Right>
cno b <C-Left>
ino f <C-Right>
ino b <C-Left>
