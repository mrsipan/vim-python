" Vim filetype plugin local extensions
" Language:	Python
" Maintainer:	Zvezdan Petkovic <zpetkovic@acm.org>	
" Last Change:	$Date: 2008/05/29 15:58:55 $
" Version:	$Id: python.vim,v 1.7 2008/05/29 15:58:55 zvezdan Exp zvezdan $

if exists("b:did_ftplugin")
	finish
endif
" The global plugin will do this
" let b:did_ftplugin = 1

let s:save_cpo = &cpo
set cpo&vim

" Format options should be defined in the global ftplugin
setlocal fo-=t fo+=croql

" Highlight more
let python_highlight_all = 1
" Have to reload syntax to take the above into account
if &t_Co > 2 || has("gui_running")
	syntax enable
endif

" Indent any continuation line 'shiftwidth' spaces
let g:pyindent_open_paren = '&sw'
let g:pyindent_nested_paren = '&sw'
let g:pyindent_continue = '&sw'

iabbrev <buffer> #! #!/usr/bin/python<Esc>h

if !hasmapto('<Plug>PythonInsertStub')
	map <buffer> <unique> <LocalLeader>() <Plug>PythonInsertStub
	map <buffer> <unique> <LocalLeader>9 <Plug>PythonInsertStub
endif
noremap <buffer> <script> <Plug>PythonInsertStub <SID>InsertStub

" Can't make it local to the buffer. Comment out if that bothers you!
noremenu <script> &Plugin.P&ython.Insert\ &Stub<Tab>\\() <SID>InsertStub

noremap <silent> <buffer> <SID>InsertStub
			\ :call <SID>InsertStub(expand("<cword>"))<CR>

if !hasmapto('<Plug>PythonCommentOut')
	map <buffer> <unique> <LocalLeader>- <Plug>PythonCommentOut
	map <buffer> <unique> <LocalLeader>+ <Plug>PythonUncomment
	map <buffer> <unique> <LocalLeader>= <Plug>PythonUncomment
endif
noremap <buffer> <script> <Plug>PythonCommentOut <SID>CommentOut
noremap <buffer> <script> <Plug>PythonUncomment <SID>Uncomment

" Can't make it local to the buffer. Comment out if that bothers you!
noremenu <script> &Plugin.P&ython.&Comment\ Out<Tab>\\- <SID>CommentOut
noremenu <script> &Plugin.P&ython.&Uncomment<Tab>\\+ <SID>Uncomment

noremap <silent> <buffer> <SID>CommentOut :call <SID>CommentOut()<CR>
noremap <silent> <buffer> <SID>Uncomment :call <SID>Uncomment()<CR>

if !exists("*s:InsertStub")
	function s:InsertStub(name)
		if a:name == ""
			echoerr "Function name expected!"
			echo "Type in the function name. "
				\ "Position the cursor on it. "
				\ "Then insert stub."
			return
		endif
		let long = tolower(input("Long header (y/[n])? ")) == "y"
		let header = long ? 
					\ "\<CR>Description:\<CR>"
					\ . "Precondition:\<CR>"
					\ . "Warning:\<CR>"
					\ . "Lock required:\<CR>"
					\ . "See also:\<CR>"
					\ . "Returns:\<CR>"
				\ :
					\ ""
		let backlines = long ? 11 : 4
		execute "normal 0d$I"
			\ . "#\<CR>"
			\ . " " . a:name . " - \<CR>"
			\ . header . "\<CR>"
			\ . "\<Esc>0d$I"
			\ . "def " . a:name . "():\<CR>"
			\ . "print \"This is " . a:name . "\"\<CR>"
			\ . "\<BS>\<Esc>"
			\ . backlines . "-$"
	endfunction
endif

if !exists(":InsertStub")
	command -buffer -nargs=1 InsertStub :call s:InsertStub(<q-args>)
endif

if !exists("*s:CommentOut")
	function s:CommentOut() range
		let indents = []
		for lnum in range(a:firstline, a:lastline)
			if getline(lnum) !~ '\S'
				continue
			endif
			call setpos(".", [0, lnum, 1, 0])
			execute "normal ^"
			call add(indents, virtcol(".") - 1)
		endfor
		let offset = empty(indents) ? 0 : min(indents)
		let save_ve = &virtualedit
		set virtualedit=all
		for lnum in range(a:firstline, a:lastline)
			if getline(lnum) !~ '\S' && offset > 0
				continue
			endif
			call setpos(".", [0, lnum, 1, offset])
			execute "normal i# "
		endfor
		let &virtualedit = save_ve
	endfunction
endif


if !exists(":CommentOut")
	command -buffer -range CommentOut :<line1>,<line2>call s:CommentOut()
endif

if !exists("*s:Uncomment")
	function s:Uncomment() range
		execute a:firstline . "," . a:lastline
			\ . 's!#\+\s\=\(.*\)!\1!'
	endfunction
endif

if !exists(":Uncomment")
	command -buffer -range Uncomment :<line1>,<line2>call s:Uncomment()
endif

let &cpo = s:save_cpo
unlet s:save_cpo
