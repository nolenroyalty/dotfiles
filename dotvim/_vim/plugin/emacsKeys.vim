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

"and a few for insert mode too
ino <C-a> <C-o>I
ino <C-e> <C-o>A
ino <C-f> <Right>
ino <C-b> <Left>
ino <C-d> <Del>

"some weirder alt-based hotkeys for commandline as well
cno f <C-Right>
cno b <C-Left>
cno  <End><C-u>

"I try to use ctrl-c so that I can use escape based hotkeys in insert mode
ino f <C-Right>
ino b <C-Left>
ino  
