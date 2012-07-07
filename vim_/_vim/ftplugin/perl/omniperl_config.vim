"This is a auto generated configuration file for the 'OmniPerl' plugin.
"Hack away! If you want a fresh and new one, simply delete it.

"This is a string value with comma separated items.
"These modules will be completely ignored in the inheritance tree.
"Default  : 'Exporter,DynaLoader,AutoLoader' 
if !exists("g:OmniPerl_Blacklist")
    let g:OmniPerl_Blacklist = 'DynaLoader,Exporter,AutoLoader'
endif

"This is a string value with comma separated items.
"Single words on one line in the pod are parsed.
"with type 'unknown'.This determines if and as what kind
"these items will be included in the completion list.
"It can be configured on a per module basis.
"See: g:OmniPerl_Module_Conf for possible values
if !exists("g:OmniPerl_Handle_Unknown_As")
    let g:OmniPerl_Handle_Unknown_As = ''
endif

"This is a string value holding a system command.
"If you are using some strange os, you may specify
" a different method to access a manual page.
"Every occurrence of the string _MODULE_ will be
"substituted with the real module name.
"Error messages (aka stderr) should be suppressed,
"control characters filtered. This command must write
"the manpage to 'stdout'.
"Note: Having one of both (perl or man) commands maybe
" sufficient depending on your system.
"The default is coded in the perl script and it is:
" '(man _MODULE_ | col -b ) 2>/dev/null'
if !exists("g:OmniPerl_Man_Cmd")
    let g:OmniPerl_Man_Cmd = ''
endif

"This is a number.
"This is the maximal number of entries ( multi-level hashes
" with all kinds of infos about a module and its super-modules )
"in the cache.
"Set it to 0 to disable caching.
if !exists("g:OmniPerl_Max_Cache")
    let g:OmniPerl_Max_Cache = 20
endif

"Here you may configure the plugin on a per module basis.
"Every key is a module name or a prefix of it.
"When the plugin looks for a config it will choose the
"one with the longest match.
"In the sub hashes 5 keys are recognized : 
"Note: These are all strings.
"'isa'            A comma separated string containing the 
"                 super-modules.
"'isa_regex'      A (vim) regex that finds one or many
"                 super-modules of the current one
"                 in the pod/man page.
"                 The string '_MODULE_' will be subst.
"                 with the current module.
"These both override @Module::ISA.

"'custom_regex'   A (perl!) regex that finds 
"                 members of the module in the man/pod.
"                 Normally the script knows what to look
"                 for, but sometimes you know it better.
"'custom_handle_as'  A comma separated list.
"                 This is what the found matches will
"                 become.
"                 Possible values: 'functions'
"                 'class_vars','instance_methods',
"                 and 'class_methods'.
"                 Note: All plural.
"'unknown_handle_as' This overrides the global variable
"                 'g:OmniPerl_Handle_Unknown_As'
"                 See: above for possible values.
if !exists("g:OmniPerl_Module_Conf")
    let g:OmniPerl_Module_Conf = 
        \{
        \'XML::DOM': {
        \'handle_unknown_as': 'instance_methods',
        \ 'isa_regex': '_MODULE_\s*extends\s*\zs\(\w\|:\)*\ze'}
        \,
        \ 'Gtk2::': {
        \'isa': 'Glib::Object',
        \ 'isa_regex': '.*+--*\zs\%(\w\|:\)*\ze\s*\n\s*+--*_MODULE_.*'}
        \,
        \ 'Gtk2::SimpleList': {
        \}
        \}
endif

"This is a string value holding a filename.
"If this is a readable file it will be preferred,
"to use as a list of available modules.
"Otherwise other methods (2) will be tried.
"There must be one module per line.
if !exists("g:OmniPerl_Modulelist_File")
    let g:OmniPerl_Modulelist_File = ''
endif

"This is a string value holding a system command.
"See g:OmniPerl_Man_Cmd.
"Default ( build in ) : '( perldoc  _MODULE_ | col -b ) 2>/dev/null'
if !exists("g:OmniPerl_Pod_Cmd")
    let g:OmniPerl_Pod_Cmd = ''
endif

"This is a string value with comma separated items.
"What do you want to see in the pum ?
"Possible values :
" kind    -  The kind of completion, 
"            see ':h complete-functions'
" line    -  The matched line in the pod/man.
"            Includes 'args' and 'returns'
" args    -  Arguments, if available.
" module  -  The module this identifier belongs to.
" returns -  If this is available. Maybe something
"            like : 'my $return_value'
" The pum will be filled in the same order ,
" except for 'kind', which is handled by vim.
if !exists("g:OmniPerl_Pum_Context")
    let g:OmniPerl_Pum_Context = 'module,line'
endif

"This is a number.
"If it is > 0, found completions will be cut after this
"value. A '/' will be appended to signal this.
if !exists("g:OmniPerl_Pum_Max_Wordlength")
    let g:OmniPerl_Pum_Max_Wordlength = 20
endif

"The plugin does several checks, before it starts
"the first time. If they all pass, this will be set 
"to 1.
"In general do not modify this variable yourself,
" unless you want to force cooperation.
if !exists("g:OmniPerl_Sanitytests_Passed")
    let g:OmniPerl_Sanitytests_Passed = 1
endif

