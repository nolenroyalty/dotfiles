" Omni support for perl
" Version    : v1_1
" Date       : 2007-06-17 10:31:09
" Maintainer : A.Politz cbyvgmn@su-gevre.qr
"              Use 'g?$' on the above address.
" Copyright  : See the help file.

if exists('b:did_ftplugin')
  finish
endif
setl omnifunc=OmniPerl_Complete

if exists("g:OmniPerl_Loaded") && g:OmniPerl_Loaded 
  finish
endif
let g:OmniPerl_Loaded  = 1
":augroup OmniPerl
":au!
":autocmd VimLeavePre * call s:WriteConfig(s:config_file)
":augroup END

let s:my_directory      = expand("<sfile>:h")
let s:manuals           = {}         "cached manuals/pods
let s:comp_cache        = {}         "cached infos about modules, hashes provided by s:perl_script_name
let s:current_complete  = {}         "info about what kind of completion we are doing
let s:complete_infos    = {'buffer' : {}, 'ident' : "" ,'start' : -1 , 'kinds'  : "" ,'module' : "",'special' : ""}
let s:perl_script_name  = 'omniperl.pl'   "scriptname of the 'main-worker', parses the perl pods and does some other stuff
let s:available_modules = []
"Figure out what kind of dir seperator the system is using. Hopefully it is
"not something like '#', '&' or '\'. Ok that's not going to happen, mh.
let tmp                = tempname()
let s:dirsep           = tmp =~ '\' ? '\' : '/'
unlet tmp
"The config file for the global config variables like g:OmniPerl_Module_Conf.
let s:config_file      = s:my_directory.s:dirsep.'omniperl_config.vim'

let s:re_module= '\u\%(\w\|:\)*'

if !exists(":OmniPerlTest")
:command! OmniPerlTest :call s:Test()
endif
if !exists(":OmniPerlWriteConfig")
:command! OmniPerlWriteConfig :call s:WriteConfig(s:config_file)
endif
"if !exists(":OmniPerlEditConfig")
":command OmniPerlEditConfig :exec ":sp ".s:config_file
"endif
    

"called at the end of teh script, need some functions here
func! s:Init()
"Create config if it does not exists
if !filereadable(s:config_file)
  call s:SetDefaults()
  call s:Test()
  echohl Pmenu 
  call input("\nCreating config file with defaults :\n".
	\"=> ".s:config_file."\n"
	\,"< OK >")
  echohl NONE
  call s:WriteConfig(s:config_file)
else
  try
    exec ":so ".s:config_file 
  catch *
    echohl Error | echo "OmniPerl : Error sourcing config-file ( ".s:config_file." ) !"
	  \."\nVim says : ".v:exception | echohl NONE
    for v in [
	  \'g:OmniPerl_Sanitytests_Passed',
	  \'g:OmniPerl_Max_Cache ',
	  \'g:OmniPerl_Man_Cmd ',
	  \'g:OmniPerl_Pod_Cmd ',
	  \'g:OmniPerl_Blacklist ',
	  \'g:OmniPerl_Modulelist_File ',
	  \'g:OmniPerl_Pum_Context',
	  \'g:OmniPerl_Pum_Max_Wordlength',
	  \'g:OmniPerl_Handle_Unknown_As',
	  \'g:OmniPerl_Module_Conf '
	  \]
      if !exists(v)
	echohl Comment | echo "Setting default values !" | echohl NONE
	call s:SetDefaults()
	break
      endif
    endfor
  endtry
endif

let s:available_modules =  s:BuildModuleList()
if empty(s:available_modules)
  redraw!
  echohl Question
  echo "OmniPerl : None of the methods to create a module list worked.\n"
	\"Maybe you should set 'g:OmniPerl_Modulelist_File'."
  echohl NONE
endif
endfun

"The core funcions 'PerlOmni_Complete' and 'Parser' (well kind of it is).
func! OmniPerl_Complete( findstart, base )
  if !g:OmniPerl_Sanitytests_Passed
    echohl Error | echo "Tests failed ! :let g:OmniPerl_Sanitytests_Passed = 1 ,if you dare." | echohl NONE
    return 
  endif
  if a:findstart
    "Somehow vim promises to reset the cursor after this function, but
    "sometimes this doesnt seam to work, so I do it myself.
    call s:RememberPos()
    "Call the Parser to find out what we could do for our dear customer.
    call s:Parser()
    call s:ResetPos()
    return s:current_complete.start 
  else
    let result = []
    if s:current_complete.start >= 0
      if s:current_complete.special == 'unknown_ident'
	"Just informs the user
	return s:Handle_UnknownIdent(s:current_complete)
	"this is where most of the 'normal' completion is done
      elseif !empty(s:current_complete.module)
	let script_result  = s:GetCompHash(s:current_complete.module)
	for mod in keys(script_result)
	  for kind in keys(script_result[mod])
	    if s:current_complete.kinds =~ kind 
	      for member in keys(script_result[mod][kind])
		if member =~ '^'.a:base.'.' 
		      \|| s:current_complete.special =~ 'prefix_module' 
		      \&& mod.'::'.member =~ '^'.a:base.'.'
		  call add(result,s:MakeCompletionEntry(mod,kind,member,script_result))
		endif
	      endfor
	    endif
	  endfor
	endfor
      endif
	"Check the EXPORT arrays and insert the idents,
	" which the user has imported, if they
	" where not found otherwise.
	" The normal found members are preferred,
	" because they contain additional infos.
      if s:current_complete.special =~ 'exported'
	let imports = s:GetImportedMembers()
	let script_result = {}
	for mod in keys(imports)
	  call extend(script_result,s:GetCompHash(mod))
	endfor
	for mod in keys(imports)
	  if !has_key(script_result,mod)
	    continue
	  endif
	  for kind in keys(script_result[mod])
	    if kind =~ 'functions' || kind =~ 'class_vars' || kind =~ 'from_exporter'
	      for mem in keys(script_result[mod][kind])
		if !has_key(imports[mod],mem)
		  continue
		endif
		"remove all idents that where found in the normal way ( aka
		"per perl-script, so in the end we have a hash of before this
		"moment not known members.
		call remove(imports[mod],mem)
		if mem =~ '^'.a:base.'.'
		  if kind =~ 'from_exporter'
		    let entry = s:MakeCompletionEntry(mod,"exported",mem,{})
		  else
		    let entry = s:MakeCompletionEntry(mod,kind,mem,script_result)
		  endif
		  call add(result,entry)
		endif
	      endfor
	    endif
	  endfor
	  for mem in keys(imports[mod])
	    if mem =~ '^'.a:base.'.'
	      let entry = s:MakeCompletionEntry(mod,"exported",mem,{})
	      call add(result,entry)
	    endif
	  endfor
	endfor
      endif
      if s:current_complete.special =~ 'from_exporter' "means from @EXPORTS and @EXPORT_OK
	for mod in keys(s:current_complete.buffer.imports)
	  let script_result = s:GetCompHash(mod)
	  if empty(script_result)
	    continue
	  endif
	  for kind in keys(script_result[mod])
	    if kind =~ 'from_exporter' "key given by the perl script
	      for mem in keys(script_result[mod][kind])
		if mod.'::'.mem =~ '^'.a:base.'.'
		  if !has_key(script_result[mod].functions,mem) 
			\&& !has_key(script_result[mod].class_vars,mem) 

		    let tmp = s:MakeCompletionEntry(mod,kind,mem,{})
		    call add(result,tmp)
		  endif
		endif
	      endfor
	    endif
	  endfor
	endfor
      endif
	"import statement after a 'use Module...', see 'perldoc Exporter' for
	"the syntax.
      if s:current_complete.special =~ 'imports'
	let mod = s:current_complete.ident
	let script_result = s:GetCompHash(mod)
	if has_key(script_result,mod) && has_key(script_result[mod],'export')
	  for ok in keys(script_result[mod].export.ok)
	    if ok =~ '^'.a:base.'.'
	      call add(result,s:MakeCompletionEntry(s:current_complete.ident,'imports',ok.' ',{}))
	    endif
	    if '!'.ok =~ '^'.a:base.'.'
	      call add(result,s:MakeCompletionEntry(s:current_complete.ident,'imports','!'.ok.' ',{}))
	    endif
	  endfor
	  for exported in keys(script_result[mod].export.exported)
	    if exported =~ '^'.a:base.'.'
	      call add(result,s:MakeCompletionEntry(s:current_complete.ident,'imports',exported.' ',{}))
	    endif
	    if '!'.exported =~ '^'.a:base.'.'
	      call add(result,s:MakeCompletionEntry(s:current_complete.ident,'imports','!'.exported.' ',{}))
	    endif
	  endfor
	  for tag in keys(script_result[mod].export.tags)
	    if ':'.tag =~ '^'.a:base.'.'
	      call add(result,s:MakeCompletionEntry(s:current_complete.ident,'imports',':'.tag.' ',{}))
	    endif
	    if '!:'.tag =~ '^'.a:base.'.'
	      call add(result,s:MakeCompletionEntry(s:current_complete.ident,'imports','!:'.tag.' ',{}))
	    endif
	  endfor
	endif
      endif
      if s:current_complete.special =~ 'literal'
	for i in s:current_complete.literal
	  call add(result,s:MakeCompletionEntry("",'literal',i,{}))
	endfor
      endif
      "if s:current_complete.special =~ 'hash'
	"for h in s:current_complete.hash
	  "if h =~ '^'.a:base
	    "let comp = matchstr(h,a:base.'\(->\)\?{[^}]*}\ze')
	    "let entry = s:MakeCompletionEntry('','hashes',comp,{})
	    "call add(result,entry)
	  "endif
	"endfor
      "endif
      "All available modules we know of.
      if s:current_complete.kinds =~ 'modules_all'
	for mod in s:available_modules
	  if mod =~ '^'.a:base.'.'
	    call add(result,s:MakeCompletionEntry('','modules',mod,{}))
	  endif
	endfor
	"Mostly the completion is only done for modules, that 
	"have a imported module as a prefix.
	"I think that makes sense.
      elseif s:current_complete.kinds =~ 'modules\(,\|$\)'
	for mod in s:available_modules
	  for imp in keys(s:current_complete.buffer.imports)
	    if mod =~ '^'.a:base.'.' && mod =~ '^'.imp.'::' && mod != a:base
	      call add(result,s:MakeCompletionEntry('','modules',mod,{}))
	    elseif mod == a:base
	      call add(result,s:MakeCompletionEntry('','modules',mod.'::',{}))
	      call add(result,s:MakeCompletionEntry('','modules',mod.'->',{}))
	    endif
	  endfor
	endfor
	for imp in keys(s:current_complete.buffer.imports)
	  if imp =~ '^'.a:base.'.'
	    call add(result,s:MakeCompletionEntry('','modules',imp,{}))
	  elseif imp == a:base
	    call add(result,s:MakeCompletionEntry('','modules',imp.'::',{}))
	    call add(result,s:MakeCompletionEntry('','modules',imp.'->',{}))
	  endif
	endfor
      endif
    endif
  endif
  call sort(result,"s:SortCompResult")
  "Checks the cache and probably removes least used informations from it.
  "Depends on OmniPerl_Max_Cache
  call s:CleanUp()
  return result
endfun

"
"
"1. class_vars       - variables that are referred to like Foo::Bar::Variable
"2. class_methods    - methods that are called on a module name like Foo::Bar->setValue(42)
"3. instance_methods - which are called on an object like "$obj->setAnotherValue(2*42)
"4. functions        - plain subroutines, called on a module name like Foo::Bar::sub5(8)
"5. exported         - subs (or functions) , vars (or whatever is beeing imported )
"                    - which are in the current namespace, this is recognized
"                    - via a use statement like 'use Foo qw(somesubs);'
"6. from_exporter    - the perl script askes the module about its EXPORTS and EXPORT_OK
"                    - arrays. Since this is a dead sure thing for finding members, they will be
"                    - added to the completion result.
"

func! s:Parser()
  "Copy the sample
  let s:current_complete = copy(s:complete_infos)
  let comp = s:current_complete
  let lnum = line('.')
  let col = col('.')
  let line = getline(lnum)
  let prev_line = getline(lnum-1)
  let prev_line = lnum-1 > 0 ? prev_line : ""
  let context = prev_line.line
  let pos = len(prev_line) + col 
  "CollectFileInfos traverses the buffer and changes the cursor.
  "If the cursor was between columns it can't be restored.
  "Therefore this has to be called after saving the current col
  let s:current_complete.buffer = s:CollectFileInfos()
  "This should match an object type of call (method or var)
  if context =~ '.*->\s*\zs\w*\%'.pos.'c\%(\s\|;\|$\)'
    let start =  match(context , '.*->\s*\zs\w*\%'.pos.'c\%(\s\|;\|$\)') 
    let member = matchstr(context,'.\{-}\zs'.s:re_module.'\ze\s*->\s*\w*\%'.pos.'c\%(\s\|;\|$\)')
    if !empty(member)
      " classmember
      let comp.module = member
      let comp.kinds = 'class_methods'
      let comp.start = start - len(prev_line)
    else
      "think of it as an instance member...
      let member = matchstr(context,'.\{-}\zs[@%\$\*]\(\w\|[->{}"'."'".'\$]\)\+\(\[\d\+\]\)\?\ze\s*->\s*\w*\%'.pos.'c\%(\s\|;\|$\)')
      let module = s:FindIdent(member,0)
      if !empty(module)
	let comp.module = module
	let comp.ident = member
	let comp.kinds = 'instance_methods'
	let comp.start = start - len(prev_line)
      else
	"let hashes = s:CollectHash(member)
	"if !empty(hashes)
	"let comp.special = 'hash'
	"let comp.hash = hashes
	"let comp.ident = member
	"let comp.start = start - len(prev_line)
	"else
	let comp.special = 'unknown_ident'
	let comp.ident = member
	let comp.start = start - len(prev_line)
      endif
    endif
    return
  endif
  "while the above code used 2 lines , these are matched only against the current line
  let pos = col
  let start  =  match(line , '^\s*use\s\s*\u\(\w\|:\)*\s\s*\zs\%'.pos.'c\%(;\|\s\|$\)')
  if start >= 0
    let comp.special = 'literal'
    let comp.literal = [ 'qw( ' ]
    let comp.start=start
    return
  endif
  "this inserts token from the EXPORT arrays and hashes ( identifier and tags )
  let start  =  match(line , '^\s*use\s\+'.s:re_module.'\s\+qw.\%(\%(\w\|:\|!\)*\s\)*\s*\zs!\?:\?\w*\%'.pos.'c\%(;\|)\|\s\|$\)')
  if start >= 0
    let module  =  matchstr(line , '^\s*use\s\s*\zs\(\w\|:\)*\ze.*')
    let comp.special = 'imports,literal'
    let comp.literal = [ ');' ]
    let comp.ident = module
    let comp.start = start
    return
  endif
  " put some modules from our module list after a use statement.
  let start  =  match(line , '^\s*\%(use\|require\)\s\s*\zs\(\w\|:\)*\%'.pos.'c\%(;\|\s\|$\)')
  if start >= 0
    let comp.module = ""
    let comp.kinds = 'modules_all'
    let comp.start = start
    return
  endif
  " something with starting uppercase and :: in it
  " does the user want a module here ?
  " or a sub ?
  " The problem is, that at this point, we don't know  if this
  " is already a valid module or not AND that it could be a prefix of dozends of other models
  " as well.
  " e.g. :  Foo::Ba{cursor} could become : 
  "	    Foo::Bar  - a module
  "	    Foo::BarVar - a variable in Foo
  " The problem is where to set the start of the completion.
  " I set it to the beginning of the whole word and let the Completion func,
  " put the module in front of it later, if there are any matches.
  " So  I pretend that it is a valid module.
  let start= match(line,'.\{-}\zs'.s:re_module.'::\w*\%'.pos.'c\%(\s\|\s*;\|$\)')
  if start >= 0
    let class = matchstr(line,'.\{-}\zs'.s:re_module.'\ze::\w*\%'.pos.'c\%(\s\|\s*;\|$\)')
    let comp.module = class

    if line =~ '^.*new\s\+'.class.'::\w*\%'.pos.'c'
      let comp.kinds = 'modules'
    elseif line =~ '^.*\(\$\|@\|%\)'.class.'::\w*\%'.pos.'c'
      let comp.kinds = 'class_vars,modules'
      let comp.special = 'prefix_module,from_exporter'
    else
      let comp.kinds = 'functions,modules'
      let comp.special = 'prefix_module,from_exporter'
    endif
    let comp.start = start
    "else
    "let start = match(context , '.\{-}}\zs.*\%'.pos.'c\%(\s\|$\)')
    "let start = match(context,'.\{-}\zs\$\(\w\|->\|[{}"'."'".'\$]\)\+\ze\%'.pos.'c\%(\s\|;\|$\)')
    "if start >= 0
    "let member = matchstr(context,'.\{-}\zs\$\(\w\|->\|[{}"'."'".'\$]\)\+\ze\%'.pos.'c\%(\s\|;\|$\)')
    "let hashes = s:CollectHash(member)
    "let comp.special = 'hash'
    "let comp.hash = hashes
    "let comp.ident = member
    "let comp.start = start - len(prev_line)
    return
  endif
  "anywhere, anything , almost
  "Ok we have hopefully some attached chars, but no '::' or '->' anywhere near it.
  let start = match(line , '.\{-}\zs\w*\%'.pos.'c\%(\s\|$\)')
  if start >= 0
    let comp.module = ""
    let comp.kinds =  'modules'
    let comp.start = start
    let comp.special = 'exported'
    return
  endif
endfun

func! s:CollectFileInfos( )
  let res = { 'base' : "", 'imports' : {} ,'comments' : {}, 'subs': {} }
  let lnr = 1
  call s:RememberPos()

  while lnr < line('$')
    let line = getline(lnr)
    "strip multi line comments
    if line =~ '^=\a' 
      let c_start=lnr
      let lnr+=1 
      while lnr < line('$') && getline(lnr) !~ '^=cut'
	let lnr+=1
      endwhile
      let res.comments[c_start]=lnr
      let lnr+=1
      continue
    endif
    "TODO This cuts other things as well.
    if line =~ '#'
      let line = matchstr(line,'^[^#]*')
    endif
    if line =~ '^\s*$'
      let lnr+=1
      continue
    endif
    if line =~ '^\s*sub '
      exec ":".lnr
      call search('{','W')
      let context=join(getline(lnr,line('.')),'')
      let sub = matchstr(context,'^\s*sub \s*\zs\w\+\ze\s*{')
      let indent = indent(lnr) 
      if !empty(sub)
	if !search('^'.repeat(' ',indent).'}','W') 
	      \&& !search('^\s*sub ','W')
	  normal G
	endif
	let res.subs[sub] = {}
	let res.subs[sub].start = lnr
	let res.subs[sub].end = line('.')
      endif
    elseif line =~ '^\s*use '
      exec ":".lnr
      call search(';','W')
      let context=join(getline(lnr,line('.')),'')
      let module=matchstr(line, '^\s*use \s*\zs\%(base\|'.s:re_module.'\)\ze')
      if !empty(module)
	let attr = matchstr(context, '^\s*use \s*'.module.'\s\+\(qw\)\?\zs[^;]\{-}\ze\s*;')
	if module == 'base'
	  let res.base=attr
	else
	  let res.imports[module]=attr
	endif
      endif
    endif
    let lnr+=1
  endwhile
  call s:ResetPos()
  return res
endfun

func! s:IsMultiComment( lnr )
  let comments = s:current_complete.buffer.comments
  for start in keys(comments)
    let end = comments[start]
    if a:lnr >= start && a:lnr <= end
      return 1
    endif
  endfor
  return 0
endfun

func! s:InSub( lnr )
  let subs = s:current_complete.buffer.subs
  for sub in keys(subs)
    if subs[sub].start <=a:lnr && subs[sub].end >= a:lnr
      return  [ sub, subs[sub].start, subs[sub].end ]
    endif
  endfor
  return []
endfun
                      
"Tries to find a definition for ident,
"probably calls itself.
func! s:FindIdent( ident, calls )
  if a:calls  > 3
    return ""
  endif
  if empty(s:current_complete.buffer)
    let s:current_complete.buffer = s:CollectFileInfos()
  endif
  let lnr = line('.')
  let sub =  s:InSub( lnr )
  let ident = escape(a:ident,'\')
  while search('^\s*\(my \|our \)\?\s*\%((\%([^,=]*,\)*\s*\V'.ident.'\m\s*\%(,[^,=]*\)*)\|\V'.ident.'\m\)\_\s*=\_\s*\zs','bW')
    if s:IsMultiComment(line('.'))
      continue
    endif
    let reg_save = @l
    let @l=""
    normal "lyt;
    if empty(@l)
      normal "ly$
    endif
    let line = substitute(@l,"\n","","g")
    let @l = reg_save
    " sub[0] ~ name
    " sub[1] ~ start
    " sub[2] ~ end
    if !empty(sub) && line('.') > sub[1]
      if getline('.')  =~ '^.*#.*'.s:re_module
	let module = matchstr(getline('.'),'^.*#.\{-}\zs'.s:re_module)
	return module
      elseif line =~ '^\%(new\)\?\s*'.s:re_module
	let module = matchstr(line,'^\%(new\)\?\s*\zs'.s:re_module)
	return module
      elseif line =~ '^\%(@_[^\[]\|pop\>\|shift\>\)' 
	let pos  = getpos('.')
	normal G$
	while search(sub[0].'\s*\zs(','Wb')
	  if s:IsMultiComment(line('.'))
	    continue
	  endif
	  let sub_pos = getpos('.')
	  let lnr = line('.')
	  "let reg_save = V@l
	  "let @l=""
	  "normal "ly%
	  "let args = split(@l,'\(\s*,\s*\|(\s*\|\s*)\)')
	  "let @l = reg_save
	  let args_ = matchstr(getline(lnr),sub[0].'\s*\zs([^;]*)'
	  let args = split(args_,'\(\s*,\s*\|(\s*\|\s*)\)')
	  call cursor(pos[1],pos[2])
	  if !empty(args)
	    if line =~ '^@_'
	      call search('^\s*\(my \|our \)\?\s*\zs(','Wb')
	      "let @l = reg_save
	      "let @l=""
	      "normal "ly%
	      "let sub_args = split(@l,'\(\s*,\s*\|(\s*\|\s*)\)')
	      "let @l = reg_save
	      let sub_args_ = matchstr(getline(lnr),sub[0].'\s*\zs([^;]*)'
	      let sub_args = split(sub_args_,'\(\s*,\s*\|(\s*\|\s*)\)')
	      if len(args) == len(sub_args)
		for i in range(len(sub_args))
		  if sub_args[i] == ident
		    call cursor(sub_pos[1],sub_pos[2])
		    return s:FindIdent(matchstr(args[i],'^\s*\zs\S*\ze'),a:calls+1)
		  endif
		endfor
	      endif
	    else
	      call cursor(sub[1],1)
	      while search('\zs\%(shift\|pop\)\>\_.*\%'.pos[1].'l\%'.pos[2].'c','W') && !empty(args)
		if expand('<cword>') =~ 'shift'
		  call remove(args,0)
		else
		  call remove(args,-1)
		endif
	      endwhile
	      if len(args) > 0
		call cursor(pos[1],pos[2])
		if expand('<cword>') =~ 'shift'
		  let ident = remove(args,0)
		else
		  let ident = remove(args,-1)
		endif
		call cursor(sub_pos[1],sub_pos[2])
		return s:FindIdent(matchstr(ident,'^\s*\zs\S*\ze\s*'),a:calls+1)
	      endif
	    endif
	  endif
	  call cursor(sub_pos[1],sub_pos[2])
	endwhile
      endif
    elseif !empty(s:InSub(line('.')))
      let in_sub_match = getpos('.')
    else
      if getline('.')  =~ '^.*#.*'.s:re_module
	let module = matchstr(getline('.'),'^.*#.\{-}\zs'.s:re_module)
	return module
      elseif line =~ '^\%(new\)\?\s*'.s:re_module
	let module = matchstr(line,'^\%(new\)\?\s*\zs'.s:re_module)
	return module
      endif
    endif
  endwhile
  if exists('in_sub_match')
    call cursor(in_sub_match[1],in_sub_match[2])
    if getline('.')  =~ '^.*#.*'.s:re_module
      let module = matchstr(getline('.'),'^.*#.\{-}\zs'.s:re_module)
      return module
    elseif line =~ '^\%(new\)\?\s*'.s:re_module
      let module = matchstr(line,'^\%(new\)\?\s*\zs'.s:re_module)
      return module
    endif
  endif
  return ""
endfun

"func! s:CollectHash( ident )
  "let result = []
  "let lnr=1
  "while lnr < line('$')
    "let line = getline(lnr)
    "if line =~ '^=\a' 
      "let c_start=lnr
      "let lnr+=1 
      "while lnr < line('$') && getline(lnr) !~ '^=cut'
	"let lnr+=1
      "endwhile
      "let res.comment[c_start]=lnr
      "let lnr+=1
      "continue
    "endif
    "if line =~ '#'
      "let line = matchstr(line,'^[^#]*')
    "endif
    "if line =~ '^\s*$'
      "let lnr+=1
      "continue
    "endif
    "if line =~ '\s*\zs\V'.a:ident.'\m\(->\|{\)'
      "let context = join(getline(lnr,lnr+1),'')
      "if !empty(context)
	"let hash = matchstr(context,'\V'.a:ident.'\m\%(\%(->\)\?{[^}]*}\)*\ze')
	"call add(result,hash)
      "endif
    "endif
    "let lnr+=1
  "endwhile
  "return result
"endfun
"

func! s:GetSortValue( kind )
  if a:kind =~ 'export\|import\|function'
    return 5
  elseif a:kind =~ 'instance_methods'
    return 10
  elseif a:kind =~ 'class_methods'
    return 15
  elseif a:kind =~ 'class_vars'
    return 20
  "elseif a:kind =~ 'hashes'
    "return 30
  else
    return 100
  endif
endfun

"Create a hash to return in the PerlOmni_Complete func , according to the user
"specs.  Handle various special kinds differently.  Adds keys 'kind2' and
"'sortvalue' for later proper sorting. 
"Hash must be empty or have keys hash[module][kind][member]
"
func! s:MakeCompletionEntry(module, kind, member, hash )
  let result = {}
  let result.sortvalue = s:GetSortValue( a:kind )
  let result.kind2 = a:kind
  if s:current_complete.special =~ 'prefix_module' && a:kind !~ 'modules'
    let result.word = a:module.'::'.a:member
  else
    let result.word = a:member
  endif

  let result.abbr = a:member
  if a:kind == 'functions' || a:kind =~ 'methods' 
    let result.word.='('
    let result.abbr.='('
  endif
  if g:OmniPerl_Pum_Max_Wordlength > 0 && len( a:member ) > g:OmniPerl_Pum_Max_Wordlength
    let result.abbr = strpart(a:member,0,g:OmniPerl_Pum_Max_Wordlength).'/'
  endif

  "Watch out for a:hashes which
  "  dont have all expected keys.

  let menu_kinds = split(g:OmniPerl_Pum_Context,',')
  if !empty(a:hash) 
    let mem_hash = a:hash[a:module][a:kind][a:member]
  else
    let mem_hash = {}
  endif
  if !empty(menu_kinds)
    let menu = ""
    for i in menu_kinds
      if i == 'kind' && a:kind !~ 'modules'
	if a:kind =~ 'methods' 
	  let result.kind = 'm'
	elseif a:kind == 'functions'
	  let result.kind = 'f'
	elseif a:kind =~ 'vars'
	  let result.kind = 'v'
	else 
	  let result.kind = '?'
	endif
      elseif i == 'module'
	let menu.=a:module.' '
      elseif !empty(mem_hash)
	if i == 'args' &&  has_key(mem_hash,'args')
	  let menu.=mem_hash.args.' '
	elseif i == 'line' &&  has_key(mem_hash,'line')
	  let menu.=mem_hash.line.' '
	elseif i == 'returns' &&  has_key(mem_hash,'line') && mem_hash.line =~ '\%(^.*->.*\)\@<!=[^>]'
	  let menu.=matchstr(mem_hash.line,'^.\{-}\ze=').' '
	endif
      endif
    endfor
    let result.menu=menu
  endif
  "Show some lines from the manual in the pvw.
  "hash.lnum is the line where the script found the 
  "most valued occurence of some member.
  "The manual should have been added right before
  "in s:GetCompHash ,but just in case....
  if &completeopt =~ 'preview' && !empty(mem_hash) && has_key(mem_hash,'lnum') && has_key(s:manuals,a:module)
    let start = mem_hash.lnum - 1 
    let manual = s:manuals[a:module]
    let context_before = 0
    while context_before < 5 && start > 0
      if manual[start-1] =~ '^\s*$'
	break
      else
	let start-=1
	let context_before+=1
      endif
    endwhile
    let end = start + &previewheight
    let end = end < len(manual) ? end : len(manual) - 1
    let preview = join(manual[start : end],"\n")
    let preview.="\n(...)"
    let result.info = preview
  endif
  return result
endfun

"Parses the import statements , see 'perldoc Exporter' for details.
func! s:GetImportedMembers( )
  let result = {}
  let imports = s:current_complete.buffer.imports
  for mod in keys(imports)
    let imp = {}
    let script_result = s:GetCompHash(mod)
    if has_key(script_result,mod) && has_key(script_result[mod],'export')
      let attr = imports[mod]
      let export = script_result[mod].export
      if empty(attr)
	for i in keys(export.exported)
	  let imp[i]=1
	endfor
      elseif attr =~ '^(\s*)$'
	"nothing
      else
	let attr = matchstr(attr,'[("'."'".']\zs.*\ze[)"'."'".']')

	for stm in split(attr)
	  if stm =~ '^!'
	    if stm =~ '^!:'
	      let tag = matchstr(stm,'^!:\zs\w*')
	      if tag =~ 'DEFAULT'
		let imp = {}
	      elseif has_key(export.tags,tag)
		for i in split(export.tags[tag],',')
		  if has_key(imp,i)
		    call remove(imp,i)
		  endif
		endfor
	      endif
	    elseif stm =~ '^!/' && has('perl')
	      "TODO:
	    else
	      let ident = matchstr(stm,'^!\zs\w*')
	      if has_key(imp,ident) 
		call remove(imp,ident)
	      endif
	    endif
	  elseif stm =~ '^:'
	    let tag = matchstr(stm,'^:\zs\w*')
	    if tag =~ 'DEFAULT'
	      for i in keys(export.exported)
		let imp[i]=1
	      endfor
	    elseif has_key(export.tags,tag)
	      for i in split(export.tags[tag],',')
		let imp[i]=1
	      endfor
	    endif
	  elseif stm =~ '^/' && has('perl')
	    "TODO:
	  else
	    let ident = matchstr(stm,'^\w*')
	    if has_key(export.ok,ident)
	      let imp[ident]=1
	    endif
	  endif
	endfor
      endif
    endif
    let result[mod] = imp
  endfor
  return result
endfun

"This handles most of the lower-level stuff.
"It first looks in the cache and returns a found item.
"Everything from the module conf is handled in this func.
"If we are doing 'manual' inheritance, calls itself recursively.
func! s:GetCompHash( module )
  "Look in the cache.
  if has_key(s:comp_cache,a:module)
    let s:comp_cache[a:module].uses+=1
    return s:comp_cache[a:module].comphash
  endif
  "Just be safe.
  if empty(a:module)
    return {}
  endif
  let result= {}
  "Get the user configuration for this module, if any.
  let conf = s:GetModuleConf( a:module )
  let opts = ""
  if !empty(conf)
    "Parse the pod with a custom regex 
    if has_key(conf,'custom_regex') 
      let opts = " -u '".conf.custom_regex."' "
    endif
    if has_key(conf,'isa') || has_key(conf,'isa_regex')
      "Dont let the script look in @ISA.
      "Handle the inheritance according to 
      "'isa' - a comma seperated string with super-classes
      "and / or
      "'isa_regex' a regex to match against the pod/manual
      "		 to find them 
      let opts = " -R ".opts  
    endif
  endif
  let cmd = s:BuildScriptCmd(opts.' '.a:module)
  try
    let result = eval(system(cmd))
  catch /.*/
    echohl ERROR | echo "OmniPerl : Critical! perl-script returned malformed vimhash :\n".cmd."\n"| echohl NONE
    try
      let ret = system(cmd)
      echohl ERROR | echo ret | echohl NONE
    catch /.*/
      echohl ERROR | echo "It does not awork at all." | echohl NONE
      return {}
    endtry
    return {}
  endtry
  if !empty(conf) && !empty(result)
    "Adding the custom found matches to their proper kinds
    "according to conf.custom_handle_as :
    "The script has assigned them to result.module.custom
    if has_key(conf,'custom_regex')
      if has_key(conf,'custom_handle_as')
	let handle_as = conf.custom_handle_as
      else
	"I think these are of most interest,
	"so I set it as default, in case someone has
	"forgotten it.Would be waste to throw the
	"results away.
	let handle_as = 'instance_methods'
      endif
      for mod in keys(result)
	for member in keys(result[mod].custom)
	  for kind in keys(result[mod])
	    if kind =~ 'custom'
	      continue
	    elseif  handle_as =~ kind.'\s*\(,\|$\)' && !has_key(result[mod][kind],member)
	      let result[mod][kind][member]=result[mod].custom[member]
	    endif
	  endfor
	endfor
      endfor
    endif


    "The user can specify how to extract inheritance from the pod.
    "I had this idea , because Gtk2 doesn't provide a usefull
    "@ISA array, but the inheritance is clearly and very regular 
    "stated in the manuals.
    if has_key(conf,'isa_regex') && filereadable(result[a:module].manual)
      let result[a:module]['isa']=""
      let regex = conf.isa_regex
      let man_file = readfile(result[a:module].manual)
      if !has_key(s:manuals,a:module)
	let s:manuals[a:module] = man_file
      endif
      let regex = substitute(regex,'_MODULE_',a:module,'g')
      "Scan the whole file in parts of 15 lines, for the inheritance-regex.
      "Advance 10 lines per round.Kinda randomly chosen values.
      "I, somehow ,dont want to read probably 1000 lines in one string-var.
      for i in range(0,len(man_file),10)
	let s = i
	let e = s + 15
	let e = e < len(man_file) ? e : len(man_file)-1
	let lines = join(man_file[s : e],"\n")
	let idx = match(lines,regex)
	if idx >= 0
	  let super = matchstr(lines,regex)
	  "we found a super-module
	  if !has_key(result,super) " do we know it already ?
	    let result[a:module].isa.=super.','
	    let tmp_res = s:GetCompHash(super)
	    if !empty(tmp_res)
	      call extend(result, tmp_res)
	      call s:RemoveOverloaded(a:module,super,result)
	    endif
	  endif
	  break
	endif
      endfor
    endif
    "this is a plain comma seperated  string, no regex.
    "Again Gtk2 : Glib::Object is the super-class of all of them,
    "but the regex does not find it, because there is no
    "man page for 'Glib::InitiallyUnowed' which is the sub
    "class of 'Glib::Object'.
    "Sould be usefull anyway.
    if has_key(conf,'isa') 
      if !has_key(result[a:module],'isa')
	let result[a:module]['isa']=""
      endif
      let super2 = split(conf.isa,",")
      for s in super2
	if has_key(result,s)
	  continue
	endif
	let tmp_res = s:GetCompHash(s)
	if !empty(tmp_res)
	  let result[a:module].isa.=s.','
	  call extend(result,tmp_res)
	  call s:RemoveOverloaded(a:module,s,result)
	endif
      endfor
    endif
  endif
  "If a manpage contains single-words on one line,
  "which start with a lower-case, they are parsed
  "as 'unknown' members.
  if has_key(conf,'handle_unknown_as') 
    let unknown_as = conf.handle_unknown_as
  else
    let unknown_as = g:OmniPerl_Handle_Unknown_As 
  endif
  if !empty(unknown_as)
    for mod in keys(result)
      if !empty(result[mod].unknown)
	for mem in keys(result[mod].unknown)
	  for kind in split(unknown_as,',')
	    if has_key(result[mod],kind) && !has_key(result[mod][kind],mem)
	      let result[mod][kind][mem] = result[mod].unknown[mem]
	    endif
	  endfor
	endfor
      endif
    endfor
  endif
  "Now it is time to slurp in the manuals for
  "later reference and clean the tmp-file.
  "Note : The manuals will be kept at aprox.
  "the same length as the cache.
  for m in keys(result)
    if filereadable(result[m].manual) 
      if !has_key(s:manuals,m)
	let s:manuals[m] = readfile(result[m].manual)
      endif
      call delete(result[m].manual)
    endif
  endfor
  let s:comp_cache[a:module]={ 'comphash' : result ,'uses' : 1  }
  return result
endfun

"Build the command to invoke the perl-script. Does not exec it.
func! s:BuildScriptCmd( opts )
  let cmd = 'perl -X '.s:my_directory.s:dirsep.s:perl_script_name
  if exists('g:OmniPerl_Man_Cmd') && !empty(g:OmniPerl_Man_Cmd)
    let cmd.=' -m "'.g:OmniPerl_Man_Cmd.'"'
  endif
  if exists('g:OmniPerl_Pod_Cmd')&& !empty(g:OmniPerl_Pod_Cmd)
    let cmd.=' -p "'.g:OmniPerl_Pod_Cmd.'"'
  endif
  if exists('g:OmniPerl_Blacklist')&& !empty(g:OmniPerl_Blacklist)
    let cmd.=' -b "'.g:OmniPerl_Blacklist.'"'
  endif
  let cmd.= " ".a:opts
  return cmd
endfun

"Find the best match in the module configuration
"The user can specify some infos about a module 
"or a class of modules. See the helpfile.
func! s:GetModuleConf( module )
  let best_match = {}
  let max = -1
  for k in keys(g:OmniPerl_Module_Conf)
    let idx = matchend(a:module,k)
    if idx > max
      let max = idx
      let best_match = g:OmniPerl_Module_Conf[k]
    endif
  endfor
  return best_match
endfun

"If we dig super-modules by ourself ( aka dont letting the perl-script handle
"inheritance ), remove overriden members from the super-module
func! s:RemoveOverloaded( module, super,hash )
  for kind in keys(a:hash[a:module])
    if kind == 'instance_methods' || kind == 'class_methods'
      for mem in keys(a:hash[a:module][kind])
	if has_key(a:hash[a:super][kind],mem)
	  call remove(a:hash[a:super][kind],mem)
	endif
      endfor
    endif
  endfor
  return a:hash
endfun

"Removes probably some items from the cache.
func! s:CleanUp()
  if len(s:comp_cache) > g:OmniPerl_Max_Cache && !empty(s:comp_cache)
    let modules = keys(s:comp_cache)
    call sort(modules,"s:SortCacheMostUsedFirst")
    while !empty(modules) && len(modules) > g:OmniPerl_Max_Cache 
      let m = remove(modules,-1)
      for m2 in keys(s:comp_cache[m].comphash)
	if has_key(s:manuals,m2)
	  call remove(s:manuals,m2)
	endif
      endfor
      call remove(s:comp_cache,m)
    endwhile
  endif
endfun

func! s:SetDefaults()
  let g:OmniPerl_Sanitytests_Passed=0
  let g:OmniPerl_Max_Cache = 20
  let g:OmniPerl_Man_Cmd = ''
  let g:OmniPerl_Pod_Cmd = ''
  let g:OmniPerl_Blacklist = 'DynaLoader,Exporter,AutoLoader'
  let g:OmniPerl_Modulelist_File = ""
  let g:OmniPerl_Pum_Context="module,line"
  let g:OmniPerl_Pum_Max_Wordlength=20
  let g:OmniPerl_Handle_Unknown_As=''
  let g:OmniPerl_Module_Conf = {
	\'XML::DOM' : { 
	\'isa_regex' : '_MODULE_\s*extends\s*\zs\(\w\|:\)*\ze' ,
	\'handle_unknown_as' : 'instance_methods' },
	\'Gtk2::SimpleList': {},
	\'Gtk2::': 
	\{'isa_regex': '.*+--*\zs\%(\w\|:\)*\ze\s*\n\s*+--*_MODULE_.*', 
	\'isa': 'Glib::Object'}}
endfun

func! s:BuildConfig( var_hash)
  let res = []
  if type(a:var_hash) == type([])
    let var_hash = {}
    for i in a:var_hash
      let var_hash[i]=1
    endfor
  else
    let var_hash = a:var_hash
  endif
  if has_key(var_hash,'_HEADER_')
    call extend(res,split(var_hash['_HEADER_'],"\n"))
  endif
  let var = 0
  for name in sort(keys(var_hash))
    if exists(name)
      if type(var_hash[name]) == type("str") && !empty(var_hash[name])
	call extend(res,split(var_hash[name],"\n"))
      endif
      unlet var
      let var = eval(name)
      call add(res,'if !exists("'.name.'")')
      if type(var) == type("str")
	let line = "    let ".name." = '".var."'"
	call add(res,line)
      elseif type(var) == type({})
	call add(res,"    let ".name." = ")
	let lines = split(string(var),'[,{}]\zs')
	for l in lines
	  call add(res,"        \\".l)
	endfor
      elseif type(var) == type([])
	call add(res,"    let ".name." = ")
	let lines = split(string(var),',[^,]*,\zs')
	for l in lines
	  call add(res,"        \\".l)
	endfor
      else
	call add(res,"    let ".name." = ".string(var))
      endif
      call add(res,'endif')
      call add(res,'')
    endif
  endfor
  if has_key(var_hash,'_FOOTER_')
    call add(res,var_hash.HEADER)
  endif
  return res
endfun

func! s:WriteConfig(file )
  let var_hash = {}
  let var_hash['_HEADER_']=
	\"\"This is a auto generated configuration file for the 'OmniPerl' plugin.\n".
	\"\"Hack away! If you want a fresh and new one, simply delete it.\n\n"
  let var_hash['g:OmniPerl_Module_Conf']=
	\"\"Here you may configure the plugin on a per module basis.\n".
	\"\"Every key is a module name or a prefix of it.\n".
	\"\"When the plugin looks for a config it will choose the\n".
	\"\"one with the longest match.\n".
	\"\"In the sub hashes 5 keys are recognized : \n".
	\"\"Note: These are all strings.\n".
	\"\"'isa'            A comma separated string containing the \n".
	\"\"                 super-modules.\n".
	\"\"'isa_regex'      A (vim) regex that finds one or many\n".
	\"\"                 super-modules of the current one\n".
	\"\"                 in the pod/man page.\n".
	\"\"                 The string '_MODULE_' will be subst.\n".
	\"\"                 with the current module.\n".
	\"\"These both override @Module::ISA.\n\n".
	\"\"'custom_regex'   A (perl!) regex that finds \n".
	\"\"                 members of the module in the man/pod.\n".
	\"\"                 Normally the script knows what to look\n".
	\"\"                 for, but sometimes you know it better.\n".
	\"\"'custom_handle_as'  A comma separated list.\n".
	\"\"                 This is what the found matches will\n".
	\"\"                 become.\n".
	\"\"                 Possible values: 'functions'\n".
	\"\"                 'class_vars','instance_methods',\n".
	\"\"                 and 'class_methods'.\n".
	\"\"                 Note: All plural.\n".
	\"\"'unknown_handle_as' This overrides the global variable\n".
	\"\"                 'g:OmniPerl_Handle_Unknown_As'\n".
	\"\"                 See: above for possible values."

  let var_hash['g:OmniPerl_Pum_Max_Wordlength'] = 
	\"\"This is a number.\n".
	\"\"If it is > 0, found completions will be cut after this\n".
	\"\"value. A '/' will be appended to signal this."
  let var_hash['g:OmniPerl_Pum_Context'] = 
	\"\"This is a string value with comma separated items.\n".
	\"\"What do you want to see in the pum ?\n".
	\"\"Possible values :\n".
	\"\" kind    -  The kind of completion, \n".
	\"\"            see ':h complete-functions'\n".
	\"\" line    -  The matched line in the pod/man.\n".
	\"\"            Includes 'args' and 'returns'\n".
	\"\" args    -  Arguments, if available.\n".
	\"\" module  -  The module this identifier belongs to.\n".
	\"\" returns -  If this is available. Maybe something\n".
	\"\"            like : 'my $return_value'\n".
	\"\" The pum will be filled in the same order ,\n".
	\"\" except for 'kind', which is handled by vim."
  let var_hash['g:OmniPerl_Modulelist_File'] = 
	\"\"This is a string value holding a filename.\n".
	\"\"If this is a readable file it will be preferred,\n".
	\"\"to use as a list of available modules.\n".
	\"\"Otherwise other methods (2) will be tried.\n".
	\"\"There must be one module per line.\n"
  let var_hash['g:OmniPerl_Man_Cmd'] =
	\"\"This is a string value holding a system command.\n".
	\"\"If you are using some strange os, you may specify\n".
	\"\" a different method to access a manual page.\n".
	\"\"Every occurrence of the string _MODULE_ will be\n".
	\"\"substituted with the real module name.\n".
	\"\"Error messages (aka stderr) should be suppressed,\n".
	\"\"control characters filtered. This command must write\n".
	\"\"the manpage to 'stdout'.\n".
	\"\"Note: Having one of both (perl or man) commands maybe\n".
	\"\" sufficient depending on your system.\n".
	\"\"The default is coded in the perl script and it is:\n".
	\"\" '(man _MODULE_ | col -b ) 2>/dev/null'\n"
  let var_hash['g:OmniPerl_Pod_Cmd'] =
	\"\"This is a string value holding a system command.\n".
	\"\"See g:OmniPerl_Man_Cmd.\n".
	\"\"Default ( build in ) : '( perldoc  _MODULE_ | col -b ) 2>/dev/null'\n"
  let var_hash['g:OmniPerl_Blacklist'] = 
	\"\"This is a string value with comma separated items.\n".
	\"\"These modules will be completely ignored in the inheritance tree.\n".
	\"\"Default  : 'Exporter,DynaLoader,AutoLoader' \n"
  let var_hash['g:OmniPerl_Max_Cache'] = 
	\"\"This is a number.\n".
	\"\"This is the maximal number of entries ( multi-level hashes\n".
	\"\" with all kinds of infos about a module and its super-modules )\n".
	\"\"in the cache.\n".
	\"\"Set it to 0 to disable caching.\n"
  let var_hash['g:OmniPerl_Handle_Unknown_As'] = 
	\"\"This is a string value with comma separated items.\n".
	\"\"Single words on one line in the pod are parsed.\n".
	\"\"with type 'unknown'.This determines if and as what kind\n".
	\"\"these items will be included in the completion list.\n".
	\"\"It can be configured on a per module basis.\n".
	\"\"See: g:OmniPerl_Module_Conf for possible values"
  let var_hash['g:OmniPerl_Sanitytests_Passed'] = 
	\"\"The plugin does several checks, before it starts\n".
	\"\"the first time. If they all pass, this will be set \n".
	\"\"to 1.\n".
	\"\"In general do not modify this variable yourself,\n".
	\"\" unless you want to force cooperation."


  call writefile(s:BuildConfig(var_hash),a:file)
  echohl Comment | echo a:file ." written." | echohl NONE
endfun

"just echos a message
func! s:Handle_UnknownIdent( base )
  let ident = s:current_complete.ident
  echohl Comment  
  echo "Don't know what a '"
	\.ident
	\."' is."
  echohl NONE
  return []
endfun

"Try to build a list of perlmodulese
func! s:BuildModuleList()
  let available_modules = []
  if filereadable(g:OmniPerl_Modulelist_File) 
    let available_modules = readfile(g:OmniPerl_Modulelist_File)
  elseif !empty(split(glob(g:OmniPerl_Modulelist_File),"\n"))
    let available_modules = readfile(split(glob(g:OmniPerl_Modulelist_File),"\n")[0])
  else
    let available_modules = s:BuildModuleListFromMan()
    if len(available_modules) < 20
      let available_modules = s:BuildModuleListFromINC()
    endif
  endif
  let i = len(available_modules)-1
  while  i >= 0 
    let available_modules[i]=matchstr(available_modules[i],'^\s*\zs\S*\ze\s*$')
    if empty(available_modules[i])
      call remove(available_modules,i)
    endif
    let i-=1
  endwhile
  return available_modules
endfun

func! s:BuildModuleListFromMan()
  if !executable('apropos')
    return []
  endif
  let mans = split(system('apropos -s3perl -r .'),"\n")
  if v:shell_error 
    return []
  endif
  call extend(mans,split(system('apropos -s3pm -r .'),"\n"))
  call map(mans,"matchstr(v:val,'^\\u\\%(\\w\\|:\\)*\\ze.*')")
  let res = []
  for m in mans
    if m !~ '^\s*$' && m !~ '\(^\|:\)\l'
      call add(res,m)
    endif
  endfor
  return res
endfun

"This method does not find 'virtual' modules like Gtk2::TreeView
func! s:BuildModuleListFromINC()
  let cmd = 'perl -e "$,=q(,);print @INC;"'
  let inc = split(system(cmd),',')
  if empty(inc)
    return []
  endif
  let result = []
  for dir in inc 
    call extend(result,s:BuildModuleListFromINCRec(dir ,''))
  endfor
  return result
endfun
func! s:BuildModuleListFromINCRec( dir, prefix )
  let dir_content = split(glob(a:dir.s:dirsep.'*'),"\n")
  let result = []
  for item in dir_content
    if isdirectory(item) 
      let module = fnamemodify(item,':t')
      if module =~ '^\u'
	call extend(result,s:BuildModuleListFromINCRec(item,a:prefix.module.'::'))
      endif
    else
      if s:dirsep == '/'
	let module = matchstr(item,'/\?\zs\u[^/]*\ze\.\c\(pm\|pod\)')
      else
	let module = matchstr(item,'\\\?\zs\u[^\\]*\ze\.\c\(pm\|pod\)')
      endif
      if !empty(module)
	call add(result,a:prefix.module)
      endif
    endif
  endfor
  return result
endfun

func! s:SortCompResult( i1, i2)
  let s1 = a:i1.sortvalue
  let s2 = a:i2.sortvalue
  if s1 != s2
    return s1 < s2 ? - 1 : s1 > s2 ? 1 : 0
  endif
  if a:i1.kind2 == 'imports' 
    if  a:i1.word =~ '^!' &&  a:i2.word !~ '^!'
      return 1
    elseif  a:i1.word !~ '^!' &&  a:i2.word =~ '^!'
      return -1
    elseif  a:i1.word !~ '^:' &&  a:i2.word =~ '^:'
      return 1
    elseif  a:i1.word =~ '^:' &&  a:i2.word !~ '^:'
      return -1
    endif
  endif
  if a:i1.kind2 == 'modules' 
    if a:i1.word =~ '::' && a:i2.word !~ '::'
      return 1
    elseif a:i1.word !~ '::' && a:i2.word =~ '::'
      return -1
    endif
  endif
  return a:i1.word > a:i2.word ? 1 : a:i1.word < a:i2.word ? -1 : 0
endfun


func! s:SortCacheMostUsedFirst( i1, i2)
  return s:comp_cache[a:i1].uses < s:comp_cache[a:i2].uses ? 1 : s:comp_cache[a:i1].uses  > s:comp_cache[a:i2].uses  ? -1 : 0 
endfun
" Remeber and Reset Cursor 
let s:cursor_pos = []
func! s:RememberPos()
  let pos = {'line': line("."),'col': col("."), 'winline': winline()}
  call add(s:cursor_pos,pos)
endfunc
func! s:ResetPos()
  if !empty(s:cursor_pos)
    let pos = remove(s:cursor_pos,len(s:cursor_pos)-1)
    keepjumps :call cursor(pos.line,pos.col)
    exe "normal zt"
    if pos.winline > 1
      exec "normal ".(pos.winline - 1) . "\<C-Y>"
    endif
  endif
endfunc

func! s:Test()
  let cmdh_save=&cmdheight
  try
    set cmdheight=25
    redraw!
    echohl TODO
    echo "OmniPerl :"
    echohl NONE
    let s:comp_cache = {}
    echo "First Run, doing some checks !\n"
    echo "Testing the perlscript with the standard module 'Carp' : "
    let comp = s:GetCompHash('Carp')
    let test1_passed = 0
    if !empty(comp)
      echo "Got some results...GOOD"
      if has_key(comp,'Carp') 
	    \&& has_key(comp['Carp'],'class_vars')
	    \&& has_key(comp['Carp'].class_vars,'Verbose')
	echo "Found '$Carp::Verbose' ...EXCELLENT"
	let test1_passed = 1
      else
	echo "...but not what I expected...BAD!"
      endif
    else
      echo "No result ... BAD"
    endif
    echo "\nTesting 'File::Basename' : "
    let comp = s:GetCompHash('File::Basename')
    let test2_passed = 0
    if !empty(comp)
      echo "Got some results...GOOD"
      if has_key(comp,'File::Basename') 
	    \&& has_key(comp['File::Basename'],'functions')
	    \&& has_key(comp['File::Basename'].functions,'basename')
	echo "Found 'File::Basename::basename' ...EXCELLENT"
	let test2_passed = 1
      else
	echo "...but not what I expected...BAD!"
      endif
    else
      echo "No result ... BAD"
    endif
    echo "\nTesting 'Net::Ping' : "
    let comp = s:GetCompHash('Net::Ping')
    let test3_passed = 0
    if !empty(comp)
      echo "Got some results...GOOD"
      if has_key(comp,'Net::Ping') 
	    \&& has_key(comp['Net::Ping'],'instance_methods')
	    \&& has_key(comp['Net::Ping'].instance_methods,'ping')
	echo "Found '$net_ping->ping' ...EXCELLENT"
	let test3_passed = 1
      else
	echo "...but not what I expected...BAD!"
      endif
    else
      echo "No result ... BAD"
    endif
    let test4_passed = 0
    echo "\nTrying to build a module list ... "
    let s:available_modules = s:BuildModuleList()
    if len(s:available_modules) > 20
      echo "Done. List contains ".len(s:available_modules)." entries."
      let test4_passed = 1
    elseif !exists('g:OmniPerl_Modulelist_File') || empty(g:OmniPerl_Modulelist_File)
      echo "Looks like it did not work properly. You should build your own list,\n"
	    \"write it to a file, one module per line and set 'g:OmniPerl_Modulelist_File'"
    elseif empty(s:available_modules)
      echo "Looks like I could not find your module list file, or it is not what I expected."
    endif
    let passed = test1_passed + test2_passed + test3_passed + test4_passed
    echo "\nBasic tests : ".passed."/4 passed."
    if passed >= 3
      echo "All fine."
    elseif passed == 2
      echo "2 tests failed, but that means probably nothing."
    elseif passed == 1
      echo "At least something did work. Maybe this tests aren't."
    else
      echo "Sorry , all failed."
      echo "If you saw some 'GOOD' messages, you have maybe completely\n".
	    \"different perl docs than me  and the plugin will still work.\n"
      if exists('g:OmniPerl_Man_Cmd') && !empty(g:OmniPerl_Man_Cmd)
	echo "Looks like your 'man_cmd' does not work properly."
	if exists('g:OmniPerl_Pod_Cmd') && !empty(g:OmniPerl_Pod_Cmd)
	  echo "Looks like your 'pod_cmd' does not work properly."
	endif
      endif
    endif
    if passed < 2
      let g:OmniPerl_Sanitytests_Passed = 0
      echo "Refusing to work. If you want to force me, you have to issue\n"
	    \"':let g:OmniPerl_Sanitytests_Passed=1'"
    else
      let g:OmniPerl_Sanitytests_Passed = 1
    endif
    echo "\nTo repeat this tests, exec the command :OmniPerlTest \n"
	  \"or remove the config file !"
    call input('< OK >')
  finally
    let &cmdheight=cmdh_save
  endtry
endfun

call s:Init()
"vim:fdm=expr:fde=getline(v:\\lnum-1)=~'^"\?fun'?'>1':getline(v\\:lnum)=~'^\?endf'?'<1':'='
