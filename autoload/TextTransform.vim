" TextTransform.vim: Text transformations extracted from unimpaired. 
"
" DEPENDENCIES:
"
" Copyright: (C) 2011 Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'. 
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>
"
" REVISION	DATE		REMARKS 
"	002	16-Mar-2011	Fix off-by-one errors with some modes and
"				'selection' settings. 
"				FIX: Parsing for l:doubledKey now also accepts
"				key modifiers like "<S-...>". 
"	001	07-Mar-2011	file creation from plugin/unimpaired.vim

function! s:Error( onError, errorText )
    if a:onError ==# 'beep'
	execute "normal \<Plug>RingTheBell" 
    elseif a:onError ==# 'errmsg'
	let v:errmsg = a:errorText
	echohl ErrorMsg
	echomsg v:errmsg
	echohl None
    endif
endfunction
function! s:Transform( algorithm, selectionModes, onError )
    let l:save_view = winsaveview()
    let l:save_cursor = getpos('.')
    let l:save_clipboard = &clipboard
    set clipboard= " Avoid clobbering the selection and clipboard registers. 
    let l:save_reg = getreg('"')
    let l:save_regmode = getregtype('"')
    let @@ = ''
    let l:isSuccess = 0

    let l:selectionModes = type(a:selectionModes) == type([]) ? a:selectionModes : [a:selectionModes]
    for l:SelectionMode in l:selectionModes
	let l:isTextObject = 0
	if type(l:SelectionMode) == type(function('tr'))
	    if call(l:SelectionMode, [])
"****D echomsg '****' string(getpos("'<")) string(getpos("'>"))
		silent! normal! gvy
	    endif
	elseif l:SelectionMode ==# 'lines'
	    silent! execute 'normal! 0v' . v:count1 . '$' . (&selection ==# 'exclusive' ? '' : 'h') . 'y'
	elseif l:SelectionMode =~# '^.$'
	    silent! execute 'normal! `<' . l:SelectionMode . '`>y'
	elseif l:SelectionMode ==# 'char'
	    silent! execute 'normal! `[v`]'. (&selection ==# 'exclusive' ? 'l' : '') . 'y'
	elseif l:SelectionMode ==# 'line'
	    silent! execute "normal! '[V']y"
	elseif l:SelectionMode ==# 'block'
	    silent! execute "normal! `[\<C-V>`]". (&selection ==# 'exclusive' ? 'l' : '') . 'y'
	else
	    let l:isTextObject = 1
	    silent! execute 'normal y' . (v:count ? v:count : '') . l:SelectionMode
	endif
"****D echomsg '****' string(l:SelectionMode) string(@@)
	
	if empty(@@)
	    unlet l:SelectionMode

	    " Reset the cursor; some selection modes depend on it. 
	    call setpos('.', l:save_cursor)
	else
	    break
	endif
    endfor

    if empty(@@)
	call s:Error(a:onError, 'Not applicable here')
    else
	let l:yankMode = getregtype('"')
	let l:transformedText = {a:algorithm}(@@)
	if l:transformedText ==# @@
	    call winrestview(l:save_view)
	    call s:Error(a:onError, 'Nothing transformed')
	else
	    " When setting the register, also set the corresponding yank mode,
	    " so that the actually yanked text is replaced (this is important
	    " for blockwise selections). Do not restore the block selection
	    " width - the transformation may have changed it, so let Vim
	    " re-calculate it based on the longest line. 
	    call setreg('"', l:transformedText, l:yankMode[0])
	    if l:isTextObject
		" Depending on the text object, the end of change mark `] may or
		" may not be one beyond the end of the text object. (Cp. with
		" selection=inclusive "i'", where it includes the ending quote
		" vs. "aw", where it is positioned on the trailing whitespace. 
		" Therefore, instead of relying on a visual re-selection, we
		" re-execute the text object (at the original position) to
		" replace the text. 
		call setpos('.', l:save_cursor)
		silent execute 'normal "_d' . (v:count ? v:count : '') . l:SelectionMode
		silent normal! P
	    else
		silent normal! gvp
	    endif

	    let l:isSuccess = 1
	endif
    endif

    call setreg('"', l:save_reg, l:save_regmode)
    let &clipboard = l:save_clipboard

    return l:isSuccess
    " silent! call repeat#set("\<Plug>unimpairedLine".a:algorithm,a:selectionModes)
endfunction

function! TextTransform#TransformOpfunc(selectionMode)
    return s:Transform(s:algorithm, a:selectionMode, 'beep')
endfunction

function! s:TransformSetup(algorithm)
    let s:algorithm = a:algorithm
    let &opfunc = 'TextTransform#TransformOpfunc'
endfunction

function! s:TransformLine( algorithm, selectionModes, repeatMapping )
    let l:count = v:count1
    if s:Transform(a:algorithm, a:selectionModes, 'beep')
	silent! call repeat#set(substitute(a:repeatMapping, '<Plug>', "\<Plug>", 'g'), l:count)
    endif
endfunction

function! TextTransform#MapTransform( mapArgs, key, algorithm, ... )
    let l:plugLineMappingName = '<Plug>unimpaired' . a:algorithm . 'Line'
    let l:plugOperatorMappingName = '<Plug>unimpaired' . a:algorithm . 'Operator'

    " This mapping repeats naturally, because it just sets a global things, and
    " Vim is able to repeat the g@ on its own. 
    execute printf('nnoremap <silent> %s %s :<C-U>call <SID>TransformSetup(%s)<CR>g@',
    \	a:mapArgs,
    \	l:plugOperatorMappingName,
    \	string(a:algorithm)
    \)

    " Repeat not defined in visual mode. 
    execute printf('xnoremap <silent> %s %s :<C-U>call <SID>Transform(%s, visualmode(), "beep")<CR>',
    \	a:mapArgs,
    \	l:plugOperatorMappingName,
    \	string(a:algorithm)
    \)

    " This mapping needs repeat.vim to be repeatable, because it contains of
    " multiple steps (visual selection, "gv" and "p" commands inside
    " s:Transform()). 
    let LineTypes = a:0 ? a:1 : 'lines'  
    execute printf('nnoremap <silent> %s %s :<C-U>call <SID>TransformLine(%s, %s, %s)<CR>',
    \	a:mapArgs,
    \	l:plugLineMappingName,
    \	string(a:algorithm),
    \	string(LineTypes),
    \	string(l:plugLineMappingName)
    \)


    execute 'nmap' a:mapArgs a:key l:plugOperatorMappingName
    execute 'xmap' a:mapArgs a:key l:plugOperatorMappingName
    let l:doubledKey = matchstr(a:key, '\(<[[:alpha:]-]\+>\|.\)$')
    execute 'nmap' a:mapArgs a:key . l:doubledKey l:plugLineMappingName
endfunction

function! TextTransform#MakeCommand( commandOptions, commandName, algorithm )
    " TODO
endfunction

" vim: set sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
