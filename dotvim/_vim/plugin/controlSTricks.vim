"=============================================================================
" File:        controlSTricks.vim
" Author:      Nolen Royalty (nolen.royalty@gmail.com)
" Version:     1.0
"=============================================================================

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

let killabove=["<C-k>d", "<C-k><C-d>", "<C-d>k", "<C-d><C-k>"]
for mapping in killabove
    exe 'map <C-s>'.mapping.' :call KillAboveLine()<Cr>'
endfor

let killbelow=["<C-j>d", "<C-j><C-d>", "<C-d>j", "<C-d><C-j>"]
for mapping in killbelow
    exe 'map <C-s>'.mapping.' :call KillBelowLine()<Cr>'
endfor

let emptyabove=["<C-k>o", "<C-k><C-o>", "<C-o>k", "<C-o><C-k>"]
for mapping in emptyabove
    exe 'map <C-s>'.mapping.' :call AddEmptyLineAbove()<Cr>'
endfor

let emptybelow=["<C-j>o", "<C-j><C-o>", "<C-o>j", "<C-o><C-j>"]
for mapping in emptybelow
    exe 'map <C-s>'.mapping.' :call AddEmptyLineBelow()<Cr>'
endfor

let swapup=["<C-k>s", "<C-k><C-s>", "<C-s>k", "<C-s><C-k>"]
for mapping in swapup
    exe 'map <C-s>'.mapping.' :call SwapWithAboveLine()<Cr>'
endfor

let swapdown=["<C-j>s", "<C-j><C-s>", "<C-s>j", "<C-s><C-j>"]
for mapping in swapdown
    exe 'map <C-s>'.mapping.' :call SwapWithBelowLine()<Cr>'
endfor
