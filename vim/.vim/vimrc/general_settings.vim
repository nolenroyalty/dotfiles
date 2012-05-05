"whitespace stuff, based on python recommendations for the most part
set tabstop=8
set expandtab
set softtabstop=4
set shiftwidth=4
set backspace=indent,eol,start
set shiftround
"let tabstop=4
"set softtabstop=8

call pathogen#infect()
syntax on
filetype on
filetype plugin indent on
colorscheme jellybeans
syntax enable

"absolute line numbers bottom right, relative line numbers on the left.  Love
"relativenumber so much..
set ruler
au BufEnter * set relativenumber
set relativenumber

"word wrapping but only line breaks when enter is pressed
au BufEnter * set wrap
set wrap
set linebreak
set nolist

"Lots of folds, helpful for tags and stuff
set foldlevelstart=20
"make replaces and whatnot default to /g, inverts /g's effect
set gdefault

" Display tabs and trailing spaces visually
set list
set listchars=tab:\ \ ,trail:·

"incremental search, case insensitive unless you use caps lock
set incsearch
set ignorecase
set smartcase

"avoid annoying prompts
set shortmess=atI
set showcmd

"not compatible with vi
set nocompatible
set mouse=a

au FileType * set formatoptions-=ro

let alphabet = "abcdefghijklmnopqrstuvwxyz"
let ALPHABET = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
let g:snips_author = "Nolen Royalty"
