function! BufLister()
python << EOF

import vim
import sys
BUFFER_NAME = "-BufferList-"

if vim.eval("g:BufListerDoingStuff") == 1:
    sys.exit()
else:
    vim.command("let g:BufListerDoingStuff=1")
    #vim.command("echo 'yo dawg %s\nyoyo'" % vim.current.buffer.name)


def get_curbufname():
    name = vim.current.buffer.name
    if not name:
        return ''
    if name.endswith(BUFFER_NAME):
        vim.command("wincmd p")
        name = vim.current.buffer.name
        vim.command("wincmd p")
    return name

def is_listed(bufname):
    return int(vim.eval("buflisted('%s')" % bufname)) != 0

def get_buffer_nums_names():
    bufnames = [b.name for b in vim.buffers]
    bufnames = [b for b in bufnames if b == BUFFER_NAME or is_listed(b)]
    return {int(vim.eval("buffer_number('%s')" % b)): b for b in bufnames}

def format_buffers(bufdict, prevname):
    keys = sorted(bufdict.keys())
    values = [vim.eval("bufname(%d)" % k).split('/')[-1] for k in keys]
    keys = ["[%s]" % k if not prevname.endswith(bufdict[k]) else "[*]" for k in keys]
    return ' - '.join("%s %s" % x for x in zip(keys, values))

def create_buflist():
    vim.command("1split %s" % BUFFER_NAME)
    vim.command("set nobuflisted")
    vim.command("wincmd K")

def set_options():
    vim.command("set noequalalways")

prevname = get_curbufname()

if not int(vim.eval("g:BufListerExists")):
    set_options()
    create_buflist()
    vim.command("let g:BufListerExists=1")

formatted_bufstring = format_buffers(get_buffer_nums_names(), prevname)

vim.command("100wincmd k")
if not vim.current.buffer.name.endswith(BUFFER_NAME):
    create_buflist()
vim.command("setl modifiable")
vim.command("hi BufListerCurrent ctermfg=126")
vim.command(r"match BufListerCurrent /\[\*\]/")
vim.current.buffer[0] = formatted_bufstring
vim.current.window.cursor = (1, 1)
if vim.current.buffer.name.endswith(BUFFER_NAME):
    vim.command("setl nomodifiable")
    vim.command("setl nomodified")
vim.command("wincmd p")
vim.command("let g:BufListerDoingStuff=0")
EOF
endfunction
