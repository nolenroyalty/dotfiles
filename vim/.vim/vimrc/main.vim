"AM I GONNA MISS IT?
"let g:bufExplorerDefaultHelp=0
"For...general settings!
source ~/.vim/vimrc/general_settings.vim
"For items specific to a language
source ~/.vim/vimrc/languages.vim
"for more general plugin stuff
source ~/.vim/vimrc/plugin.vim
"need to find a really good tab completion solution
set completeopt=menuone,longest,preview
set complete-=-i
set pumheight=10
set wildmenu
"nnoremap <C-,> ,
"nnoremap , ;
"call pathogen#infect()
"let alphabet = "abcdefghijklmnopqrstuvwxyz"
"let ALPHABET = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
"let g:snips_author = "Nolen Royalty"
"syntax on
"filetype on
"filetype plugin indent on
"set ofu=syntaxcomplete#Complete
"colorscheme jellybeans
"syntax enable
"Let's be honest...do I use anything other than python?  Lol
"au FileType python let python_highlight_all = 1
"let g:pydiction_location = '/Users/scale/.vim/vimfiles/ftplugin/pydiction/complete-dict'
"au FileType python let g:pymode_lint_jump = 1
"au FileType python syntax keyword pythonReturn return
"au FileType python hi pythonTodo ctermfg=red
"au FileType html,xhtml set autoindent
"au BufRead vv set syntax=vim
"these two shouldn't be necessary but apparently they are, some plugin must be
"resetting them and this is the easiest way to fix it
"au BufEnter * set relativenumber
"au BufEnter * set wrap
"au BufEnter python let g:pymode_lint_onfly = 1
"au BufEnter python let g:pymode_lint_write = 0
"au FileType * setglobal relativenumber
"au FileType * set formatoptions-=ro
"autocmd VimEnter * nested :call tagbar#autoopen()
"let g:tagbar_compact = 1
"let g:SuperTabDefaultCompletionType = "context"
"let g:SuperTabContextDefaultCompletionType = "<C-n>"
"au BufEnter python let ropevim_extended_complete=1
"au BufEnter python let ropevim_vim_completion=1
"au BufEnter python let ropevim_enable_autoimport=1
"au BufEnter python let let g:pep8_map='<Leader>8'
"let g:bufExplorerDefaultHelp=0
"let g:miniBufExplorerMoreThanOne=1

"set completeopt=menuone,longest,preview
"set pumheight=10
"for autocomplete
"set wildmenu
"close preview window automatically(really nice)
"autocmd VimEnter * nested :call tagbar#autoopen()
"autocmd CursorMovedI * if pumvisible() == 0|pclose|endif
"autocmd InsertLeave * if pumvisible() == 0|pclose|endif
"au FileType c,cpp,java let b:comment_leader = '//'

"____LEADER SECTION____
        let mapleader = ";"

"j      commenting out
        map <Leader>j <Leader>cc
        map <Leader>J <Leader>cu

"`      last edited buffer
        map <Leader>` :b#<Cr>

"D      delete current buffer
        map <Leader>D <C-w>k<C-w>kd<Cr><C-w>j

"b      open buffer switching
        map <Leader>b :b 

"nf     format numbers on line
        map <Leader>nf :s/\(\d\)\(\(\d\d\d\)\+\d\@!\)\@=/\1,<Cr>

"<C-d>  clone and comment out line
        map <Leader><C-d> yypk<Leader>C

"<C-t>  toggle Tagbar
        map <Leader><C-t> :TagbarToggle<Cr>

"e      open file
        map <Leader>e :e 

"F     do what we last did with force
        map <Leader>F ::!

"h      prepare to open dotfile in home dir
        map <Leader>h :e ~/.

"vv     open vimrc
        map <Leader>vv :e ~/.vim/vimrc/main.vim<Cr>

"R      Rope tricks
"        nmap <Leader>Rrn :RopeRename<Cr>

"<C-n>  NERDTree
        map <Leader><C-n> :NERDTree<Cr>

"al, Al "insert the alphabet
        map <Leader>al i<C-r>=escape(alphabet, '\/')<CR><ESC>
        map <Leader>Al i<C-r>=escape(ALPHABET, '\/')<CR><ESC>

        "C     "map leader c to comment out beginning of line, (old shitty code at end of file)
        map <Leader>C <Leader>cc

"W      leader W to write file as sudo
        map <Leader>W :w !sudo tee %

"<C-r>  Leader parenstuff for rainbowparens on off (leader-rainbow)
        "map <Leader><C-r> :RainbowParenthesesToggle<CR>:RainbowParenthesesLoadSquare<CR>:RainbowParenthesesLoadBraces<CR>

"H      "Leader h for highlight search on/off
"        map <Leader>H :set hlsearch! hlsearch?<CR>

"k      "trying leader k for last unless can think of better choice
        nmap <Leader>k :<UP>
"w      "wq to quote a word, wuq or wQ to unquote.  Uses z register
"wq, wuq, wQ, ww, w;, w', qw
        nnoremap <Leader>wq :call QuoteNormal('"')<CR>
        nnoremap <Leader>wQ :silent! normal mpeld bhd `ph<CR>
        vnoremap <silent> <Leader>wq :call Quote('"')<CR>
        vnoremap <silent> <Leader>wsq :call Quote("'")<CR>

        function! QuoteNormal(quote)
            let save = @z
            silent normal "zyiw
            let @z = a:quote.@z.a:quote
            silent normal cwzb
            let @z = save
        endfunction

        function! Quote(quote)
            let save = @"
            silent normal gvy
            let @" = a:quote . @" . a:quote
            silent normal gvp
            let @" = save
        endfunction

        "Delete {(['" surrounding shit
        noremap <Leader>d{ :<C-U>exe "normal m`".v:count1."F{x".v:count1."f}x``"<CR>
        noremap <Leader>d} :<C-U>exe "normal m`".v:count1."F{x".v:count1."f}x``"<CR>
        noremap <Leader>d( :<C-U>exe "normal m`".v:count1."F(x".v:count1."f)x``"<CR>
        noremap <Leader>d) :<C-U>exe "normal m`".v:count1."F(x".v:count1."f)x``"<CR>
        noremap <Leader>d' :<C-U>exe "normal m`".v:count1."F'x".v:count1."f'x``"<CR>
        noremap <Leader>d" :<C-U>exe 'normal m`'.v:count1.'F"x'.v:count1.'f"x``'<CR>
        noremap <Leader>d[ :<C-U>exe "normal m`".v:count1."F[x".v:count1."f]x``"<CR>
        noremap <Leader>d] :<C-U>exe "normal m`".v:count1."F[x".v:count1."f]x``"<CR>
        noremap <Leader>d< :<C-U>exe "normal m`".v:count1."F<x".v:count1."f>x``"<CR>
        noremap <Leader>d> :<C-U>exe "normal m`".v:count1."F<x".v:count1."f>x``"<CR>

"___END LEADER SECTION___

"""""""""""""""""""""#MAPPINGS#"""""""""""""""""""""
"Make ZZ more useful when I have many windows open?
map ZZ :wqa<Cr>
"make tab work right
vmap <tab> >gv
vmap <S-tab> <gv
nmap <tab> v>><esc>
nmap <S-tab> v<<<esc>
"imap <S-tab> <Backspace>
"imap <tab> <C-n>
" highlight searches
noremap <C-\> :set hlsearch! hlsearch?<CR>
"some tricks for hi/med/low with z
nmap zh z<Cr>
nmap zl zb
nmap zm z.
"c-j and c-k for quick movement, c-h and c-l for windows
map <C-j> 15j
map <C-k> 15k
"map <C-h> ^<C-w>h
"map <C-l> $<C-w>l
map <C-h> ^
map <C-l> $

"EMACS KEYBINDINGS
"start of line
cnoremap <C-a> <Home>

"back one character
cnoremap <C-b> <Left>

"delete character under cursor
cnoremap <C-d> <Del>

"end of line
cnoremap <C-e> <End>

"forward one character
cnoremap <C-f> <Right>

"recall newer command-line
cnoremap <C-n> <Down>

"recall previous (older) command-line
cnoremap <C-p> <Up>

"use Q to run macro recorded into register q
nnoremap Q @q
"C-n C-p for buffers
nmap <C-n> :bn<Cr>
nmap <C-p> :bp<Cr>
"""""""""""""""""""""END MAPPINGS"""""""""""""""""""""

"""""""""""""""""""""SETTINGS"""""""""""""""""""""
""not compatible with vi
"set nocompatible

"set mouse=a

""avoid annoying prompts
"set shortmess=atI
"set showcmd

""for autocomplete
"set wildmenu

""incremental search
"set incsearch

"ignore search case unless using uppercase letters
"set ignorecase
"set smartcase
" Able to jump between parts of an underscored_word via w, e, etc
" found this to be problematic?
"set iskeyword-=_
"""""""""""""""""""""FORMATTING STUFF""""""""""""""""""""
""absolute line numbers bottom right, relative line numbers on the left
"set ruler
""set relativenumber
""word wrapping but only line breaks when enter is pressed
"set wrap
"set linebreak
"set nolist
"" Display tabs and trailing spaces visually
"set list
"set listchars=tab:\ \ ,trail:·
""set list listchars=tab:\ \ ,trail:·
""whitespace stuff
"set tabstop=4
"set softtabstop=4
"set shiftwidth=4
"set backspace=indent,eol,start
"set shiftround
"set expandtab
"""""""""""""""""""""END FORMATTING STUFF"""""""""""""""""""""

"""""""""""""""""""""END SETTINGS"""""""""""""""""""""
"""""""""""""""""""""OLD SHITTY CODE"""""""""""""""""""""
"        map <Leader>::c 0i<C-r>=escape(b:comment_leader, '\/')<CR><Esc>j
"        map <Leader>::C 0:s/\(^[^<C-r>=escape(b:comment_leader,
"        '\/')<CR>]*\)\(<C-r>=escape(b:comment_leader,
"        '\/')<CR>\)\(.*\)/\1\3<CR>j
"        map <Leader>c @="I".b:comment_leader<Cr><Esc>j
"        map <Leader>c @="I".b:comment_leader<Cr><Esc>j
"        imap <C-\> <C-r>=b:comment_leader<Cr>
"        imap <C-g> <C-r>=b:comment_leader<Cr>
"        map <C-S-g> I<C-r>=b:comment_leader<Cr>
"        map <C-S-g> I#
"        map <Leader>c @='I`<C-`><C-V><Esc>j'<Cr>
"        map <Leader>c @='I<C-g><C-V><Esc>j'<Cr>
"        map <Leader>c @='<C-S-g><C-V><Esc>j'<Cr>


"        map <Leader>c @='I<C-v><C-r>=b:comment_leader<C-v><Esc>'<Cr>j

"        map <Leader>c :<C-U>let b:vcount = v:count1<CR>:let b:scratch =
"        @q<CR>:let @q = ";::c"<CR>:exe "normal ".<C-r>=escape(b:vcount,
"        '\/')<CR>."@q"<CR>:let @q = b:scratch<CR>
        "map <Leader>C :<C-U>let b:vcount = v:count1<CR>:let b:scratch =
        "@q<CR>:let @q = ";::C"<CR>:exe "normal ".<C-r>=escape(b:vcount,
        "'\/')<CR>."@q"<CR>:let @q = b:scratch<CR>
"settings for solarize, not used right now
"set background=dark
"let g:solarized_termcolors = 16
"let g:solarized_visibility = "high"
"let g:solarized_contrast = "low"
"colorscheme solarized
"au FileType python let g:pymode_folding = 0
"Make jk0$ work like you would expect when dealing with long lines, jk are
"problematic though when trying to do multiline jumps
"turns out all of these are annoying..."
"noremap <buffer> <silent> k gk
"noremap <buffer> <silent> j gj
"noremap <buffer> <silent> 0 g0
"noremap <buffer> <silent> $ g$
"no more doc lookup binding!
"vmap K k
"map K k
"""""THIS IS SO HELPFUL
"cnoremap <C-o> <S-Left>
"cnoremap <C-S-o> <S-Right>
"cnoremap <C-i> <S-Right>

"""""""""""""""""""""OLD SHITTY CODE"""""""""""""""""""""
