"=============================================================================
" File:        stackOverflowSearcher.vim
" Author:      Nolen Royalty (nolen.royalty@gmail.com)
" Version:     1.0
"=============================================================================

function! StackoverflowQuery()
python << EOF

import vim
import urllib2
import re

current_os = vim.eval("substitute(system('uname'), '\n', '', '')")
if current_os == "Darwin":
    url_command = "open"
else:
    url_command = "firefox"

PROMPT = "[n]ext, [p]rev, [q]uit, [o]pen"
URL = "http://stackoverflow.com"
SEARCH_URL = URL + "/search?q="
#find_pattern = re.compile(r'<div class="summary">\s*?<h3><a href="([^"]+)"[^>]*>(.*?)\s+?<div class="excerpt">\s+(.*?)</div>', re.X|re.DOTALL)
find_pattern = re.compile(r"""<div\ class="summary">\s*?<h3>   # smallest easily capturable div
                              <a\ href="([^"]+)"[^>]*>         # capture the link, and eat the chars until the href ends
                              (.*?)\s+?                        # everything after that until excerpt is the title
                              <div\ class="excerpt">\s+(.*?)   # everything after the excerpt is the..excerpt
                              </div>""", re.X|re.DOTALL)
kill_pattern = r"(<[^>]*>|&[^;]*;|\n)"

def python_input(message = PROMPT):
    vim.command('call inputsave()')
    vim.command("let user_input = input('" + message + ": ')")
    vim.command('call inputrestore()')
    return vim.eval('user_input')

def get_query(linenum, queryprompt="Enter query, or leave blank to use current line"):
    query = python_input(queryprompt)
    if not query:
        query = buf[linenum-1]
    return query.strip('"')

def get_questions(query):
    response = urllib2.urlopen(SEARCH_URL + query).read()
    vals = re.findall(find_pattern, response)
    return [[x[0], re.sub(kill_pattern, "", x[1]).strip(), re.sub(kill_pattern, "", x[2]).strip()] for x in vals]

def draw_question(value, linenum):
    url, title, summary = URL + value[0], value[1], [x.strip() for x in value[2].splitlines() if x.strip()]
    #cols = int(vim.eval("&columns"))
    cols = vim.current.window.width
    header_description = "Searching for '%s'     On Question %s of %s....----.." % (plain_query, location + 1, len(vals))
    header_description += " " * (cols - len(header_description) - 4)
    color_footer = "....----.." + " " * (cols - 14)

    to_append = ["", header_description] + ["URL: %s" % url, "", "Question title: %s" % title, ""] + summary + ["", color_footer]

    vim.command("hi PyColorVisible ctermbg=101 ctermfg=white")
    vim.command("hi PyColorInvisible ctermbg=101 ctermfg=101")
    vim.command(r"match PyColorVisible /^Searching for .\{-} On Question \d\+ of \d\+/")
    vim.command(r"2match PyColorInvisible /\.\.\.\.----\.\..*$/")

    buf.append(to_append, linenum)
    vim.command("normal 2j")
    vim.command("redraw")
    return len(val) + len(to_append)-3

def clear_question(vallen, linenum):
    del buf[linenum:linenum+vallen]


buf, cursor = vim.current.buffer, vim.current.window.cursor
linenum = cursor[0]
plain_query = get_query(linenum)
while not plain_query:
    plain_query = get_query(linenum, "Please provide a valid query")

query = "+".join(plain_query.split())
old_line = buf[linenum-1]
buf[linenum-1] = ""
vals = get_questions(query)
location = 0

vim.command("normal z.")
vim.command("normal ")
vim.command("normal ")
vim.command("normal ")
vim.command("normal ")
vim.command("normal ")
vim.command("command! -nargs=1 Silent | execute ':silent !'.<q-args> | execute ':redraw!'")

while vals:
    val = vals[location]
    question_length = draw_question(val, linenum-1)
    user_response = python_input()
    user_response = user_response.lower() if user_response else "n"

    if user_response == "q":
        break
    elif user_response == "n":
        location = (location + 1) % len(vals)
    elif user_response == "p":
        location = (location - 1) % len(vals)
    elif user_response == "o":
        vim.command("Silent %s %s%s" % (url_command, URL, val[0]))
    vim.command("normal 2k")
    clear_question(question_length, linenum)


if vals:
    vim.command("normal 2k")
    vim.command("hi clear PyColorVisible")
    vim.command("hi clear PyColorInvisible")
    clear_question(question_length, linenum)
    buf[linenum-1] = old_line
EOF
endfunction
