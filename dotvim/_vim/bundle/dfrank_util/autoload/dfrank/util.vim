" 
" this is plugin-library: DfrankUtil
"

let g:dfrank#util#version     = 102
let g:dfrank#util#loaded      = 1

if (has('win32') || has('win64'))
   let g:dfrank#util#pathSeparator = '/'
else
   let g:dfrank#util#pathSeparator = '/'
endif

" Trim(sString)
" trims spaces from begin and end of string
function! dfrank#util#Trim(sString)
   return substitute(substitute(a:sString, '^\s\+', '', ''), '\s\+$', '', '')
endfunction

" returns whether or not file exists in list
function! dfrank#util#IsFileExistsInList(aList, sFilename)
   let l:sFilename = dfrank#util#ParsePath(a:sFilename)
   if (index(a:aList, l:sFilename, 0, 1)) >= 0
      return 1
   endif
   return 0
endfunction


" ParsePath(sPath)
"   changes '\' to '/' or vice versa depending on OS (MS Windows or not), 
"   also calls simplify(), removes last slash
function! dfrank#util#ParsePath(sPath)

   if (has('win32') || has('win64'))
      "let l:sPath = substitute(a:sPath, '/', '\', 'g')
      let l:sPath = substitute(a:sPath, '\', g:dfrank#util#pathSeparator, 'g')
   else
      let l:sPath = substitute(a:sPath, '\', g:dfrank#util#pathSeparator, 'g')
   endif

   " simplify path
   let l:sPath = simplify(l:sPath)

   " removing last "/" or "\"
   let l:sPath = substitute(l:sPath, '[\\/]$', '', '')

   "let l:sLastSymb = strpart(l:sPath, (strlen(l:sPath) - 1), 1)
   "if (l:sLastSymb == '/' || l:sLastSymb == '\')
   "let l:sPath = strpart(l:sPath, 0, (strlen(l:sPath) - 1))
   "endif
   return l:sPath
endfunction

" concatenates two lists preventing duplicates
function! dfrank#util#ConcatLists(lExistingList, lAddingList)
   let l:lResList = a:lExistingList
   for l:sItem in a:lAddingList
      if (index(l:lResList, l:sItem) == -1)
         call add(l:lResList, l:sItem)
      endif
   endfor
   return l:lResList
endfunction

" returns all except last item of path
function! dfrank#util#GetPathHeader(sPath)
   let l:sPath = substitute(a:sPath, '[\\/]$', '', '')
   return fnamemodify(l:sPath, ":h")
   
   "return substitute(a:sPath, '\v^(.*)[\\/]([^\\/]+)[\\/]{0,1}$', '\1', '')
endfunction

" returns last item of path
function! dfrank#util#GetPathLastItem(sPath)
   let l:sPath = substitute(a:sPath, '[\\/]$', '', '')
   return fnamemodify(l:sPath, ":t")

   "return substitute(a:sPath, '\v^.*[\\/]([^\\/]+)[\\/]{0,1}$', '\1', '')
endfunction


function! dfrank#util#IsFileInSubdirSimple(sFilename, sDirname)
   let l:iDirnameLen = strlen(a:sDirname) + 1

   return (strpart(a:sFilename, 0, l:iDirnameLen) == a:sDirname.g:dfrank#util#pathSeparator)
endfunction

function! dfrank#util#IsFileInSubdir(sFilename, sDirname)
   let l:sDirname = dfrank#util#ParsePath(expand(a:sDirname))
   let l:sFilename = dfrank#util#ParsePath(expand(a:sFilename))

   if has('win32') || has('win64')
      let l:sDirname = tolower(l:sDirname)
      let l:sFilename = tolower(l:sFilename)
   endif

   return dfrank#util#IsFileInSubdirSimple(l:sFilename, l:sDirname)
endfunction


" IsAbsolutePath(path) <<<
"   this function from project.vim is written by Aric Blumer.
"   Returns true if filename has an absolute path.
function! dfrank#util#IsAbsolutePath(path)
   if a:path =~ '^ftp:' || a:path =~ '^rcp:' || a:path =~ '^scp:' || a:path =~ '^http:'
      return 2
   endif
   let path=expand(a:path) " Expand any environment variables that might be in the path
   if path[0] == '/' || path[0] == '~' || path[0] == '\\' || path[1] == ':'
      return 1
   endif
   return 0
endfunction " >>>


" acts like bufname({expr}), but always return absolute path
function! dfrank#util#BufName(mValue)
   let l:sFilename = bufname(a:mValue)

   " make absolute path
   if !empty(l:sFilename) && !dfrank#util#IsAbsolutePath(l:sFilename)
      let l:sFilename = getcwd().'/'.l:sFilename
   endif

   " on Windows systems happens stupid things: bufname returns path without
   " drive letter, e.g. something like that: "/path/to/file", but it should be
   " "D:/path/to/file". So, we need to add drive letter manually.
   if has('win32') || has('win64')
      if strpart(l:sFilename, 0, 1) == '/' && strpart(getcwd(), 1, 1) == ':'
         let l:sFilename = strpart(getcwd(), 0, 2).l:sFilename
      endif
   endif

   " simplify
   let l:sFilename = simplify(l:sFilename)

   return l:sFilename
endfunction



" specify default values for non-specified params in dictionary
function! dfrank#util#SetDefaultValues(dParams, dDefParams)
   let l:dParams = a:dParams

   for l:sKey in keys(a:dDefParams)
      if (!has_key(l:dParams, l:sKey))
         let l:dParams[ l:sKey ] = a:dDefParams[ l:sKey ]
      else
         if type(l:dParams[ l:sKey ]) == type({}) && type(a:dDefParams[ l:sKey ]) == type({})
            let l:dParams[ l:sKey ] = dfrank#util#SetDefaultValues(l:dParams[ l:sKey ], a:dDefParams[ l:sKey ])
         endif
      endif
   endfor

   return l:dParams
endfunction

function! dfrank#util#GetKeyFromPath(sPath)
   let l:sKey = substitute(a:sPath, '[^a-zA-Z0-9_]', '_', 'g')

   if has('win32') || has('win64')
      let l:sKey = tolower(l:sKey)
   endif

   return l:sKey
endfunction

function! dfrank#util#init()
   " dummy func
endfunction


