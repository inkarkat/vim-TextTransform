" TextTransform.vim: Text transformations extracted from unimpaired. 
"
" DEPENDENCIES:
"   - vimscript #2136 repeat.vim autoload script (optional). 
"   - visualrepeat.vim autoload script (optional). 
"
" Copyright: (C) 2011 Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'. 
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>
"
" REVISION	DATE		REMARKS 
"	004	28-Mar-2011	ENH: Allow use of funcref for a:algorithm in
"				order to support script-local transformation
"				functions. 
"	003	25-Mar-2011	ENH: Use s:TransformExpression() instead of
"				s:TransformSetup() to enable passing <count>
"				before the operator-pending mapping. 
"				Tighten pattern to detect visualmode() arguments
"				in s:Transform(). 
"				Implement TextTransform#MakeCommand() for
"				linewise application of the algorithm. 
"				ENH: Catch and report errors in algorithm. 
"				ENH: Do not make the buffer modified if no
"				transformation is done. 
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
function! s:ApplyAlgorithm( algorithm, text )
    try
	return call(a:algorithm, [a:text])
    catch /^Vim\%((\a\+)\)\=:E/
	" v:exception contains what is normally in v:errmsg, but with extra
	" exception source info prepended, which we cut away. 
	let v:errmsg = substitute(v:exception, '^Vim\%((\a\+)\)\=:', '', '')
	echohl ErrorMsg
	echomsg v:errmsg
	echohl None
    catch
	let v:errmsg = 'TextTransform: ' . v:exception
	echohl ErrorMsg
	echomsg v:errmsg
	echohl None
    endtry
endfunction
function! s:Transform( algorithm, selectionModes, onError )
    let l:save_view = winsaveview()
    let l:save_cursor = getpos('.')
    let l:save_clipboard = &clipboard
    set clipboard= " Avoid clobbering the selection and clipboard registers. 
    let l:save_reg = getreg('"')
    let l:save_regmode = getregtype('"')
    let @" = ''
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
	elseif l:SelectionMode =~# "^[vV\<C-v>]$"
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
"****D echomsg '****' string(l:SelectionMode) string(@")
	
	if empty(@")
	    unlet l:SelectionMode

	    " Reset the cursor; some selection modes depend on it. 
	    call setpos('.', l:save_cursor)
	else
	    break
	endif
    endfor

    if empty(@")
	call s:Error(a:onError, 'Not applicable here')
    else
	let l:yankMode = getregtype('"')
	let l:transformedText = s:ApplyAlgorithm(a:algorithm, @")
	if l:transformedText ==# @"
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
endfunction

function! s:TransformExpression( algorithm, repeatMapping )
    let s:algorithm = a:algorithm
    let s:repeatMapping = a:repeatMapping
    let &opfunc = 'TextTransform#TransformOpfunc'
    return 'g@'
endfunction

function! TextTransform#TransformOpfunc( selectionMode )
    let l:count = v:count1
    if s:Transform(s:algorithm, a:selectionMode, 'beep')
	" This mapping repeats naturally, because it just sets global things,
	" and Vim is able to repeat the g@ on its own. 
	" But enable a repetition in visual mode through visualrepeat.vim. 
	silent! call visualrepeat#set("\<Plug>" . s:repeatMapping . 'Visual', l:count)
    endif
endfunction

function! s:TransformLine( algorithm, selectionModes, repeatMapping )
    let l:count = v:count1
    if s:Transform(a:algorithm, a:selectionModes, 'beep')
	" This mapping needs repeat.vim to be repeatable, because it contains of
	" multiple steps (visual selection, "gv" and "p" commands inside
	" s:Transform()). 
	silent! call repeat#set("\<Plug>" . a:repeatMapping . 'Line', l:count)
	" Also enable a repetition in visual mode through visualrepeat.vim. 
	silent! call visualrepeat#set_also("\<Plug>" . a:repeatMapping . 'Visual', l:count)
    endif
endfunction

function! s:TransformVisual( algorithm, repeatMapping )
    let l:count = v:count1
    if s:Transform(a:algorithm, visualmode(), 'beep')
	" Make the visual mode mapping repeatable in normal mode, applying the
	" previous visual mode transformation at the current cursor position,
	" using the size of the last visual selection. 
	" Note: We cannot pass the count here, the <SID>Reselect "1v" would
	" swallow that. But what would a count mean in this case, anyway? 
	silent! call repeat#set("\<Plug>" . a:repeatMapping . 'Visual', -1)
	" Also enable a repetition in visual mode through visualrepeat.vim. 
	silent! call visualrepeat#set_also("\<Plug>" . a:repeatMapping . 'Visual', l:count)
    endif
endfunction

function! s:Before()
    let s:isModified = &l:modified
endfunction
function! s:After()
    if ! s:isModified
	setlocal nomodified
    endif
    unlet s:isModified
endfunction
nnoremap <expr> <SID>Reselect '1v' . (visualmode() !=# 'V' && &selection ==# 'exclusive' ? ' ' : '')
function! TextTransform#MapTransform( mapArgs, key, algorithm, ... )
    " This will cause "E474: Invalid argument" if the mapping name gets too long. 
    let l:mappingName = 'unimpaired' . (
    \	type(a:algorithm) == type('') ?
    \	    a:algorithm :
    \	    substitute(substitute(string(a:algorithm), '^function(''\(.*\)'')', '\1', ''), '<SNR>', '', 'g')
    \)
    let l:plugMappingName = '<Plug>' . l:mappingName
    let l:noopModificationCheck = 'call <SID>Before()<Bar>call setline(1, getline(1))<Bar>call <SID>After()<Bar>'

    execute printf('nnoremap <silent> <expr> %s %sOperator <SID>TransformExpression(%s, %s)',
    \	a:mapArgs,
    \	l:plugMappingName,
    \	string(a:algorithm),
    \	string(l:mappingName)
    \)

    " Repeat not defined in visual mode. 
    execute printf('vnoremap <silent> %s <SID>%sVisual :<C-u>%scall <SID>TransformVisual(%s, %s)<CR>',
    \	a:mapArgs,
    \	l:mappingName,
    \	l:noopModificationCheck,
    \	string(a:algorithm),
    \	string(l:mappingName)
    \)
    execute printf('vnoremap <silent> <script> %sVisual <SID>%sVisual',
    \	l:plugMappingName,
    \	l:mappingName
    \)
    execute printf('nnoremap <silent> <script> %sVisual <SID>Reselect<SID>%sVisual',
    \	l:plugMappingName,
    \	l:mappingName
    \)

    let LineTypes = a:0 ? a:1 : 'lines'  
    execute printf('nnoremap <silent> %s %sLine :<C-u>%scall <SID>TransformLine(%s, %s, %s)<CR>',
    \	a:mapArgs,
    \	l:plugMappingName,
    \	l:noopModificationCheck,
    \	string(a:algorithm),
    \	string(LineTypes),
    \	string(l:mappingName)
    \)


    execute 'nmap' a:mapArgs a:key l:plugMappingName . 'Operator'
    execute 'xmap' a:mapArgs a:key l:plugMappingName . 'Visual'
    let l:doubledKey = matchstr(a:key, '\(<[[:alpha:]-]\+>\|.\)$')
    execute 'nmap' a:mapArgs a:key . l:doubledKey l:plugMappingName . 'Line'
endfunction



function! s:TransformCommandLinewise( firstLine, lastLine, algorithm )
    try
	let l:lastModifiedLine = 0
	let l:modifiedLineCnt = 0
	for l:i in range(a:firstLine, a:lastLine)
	    let l:text = getline(l:i)
	    let l:transformedText = call(a:algorithm, [l:text])
	    if l:text !=# l:transformedText
		let l:lastModifiedLine = l:i
		let l:modifiedLineCnt += 1
		call setline(l:i, l:transformedText)
	    endif
	endfor

	if l:modifiedLineCnt > 0
	    execute 'normal!' l:lastModifiedLine . 'G^'
	    " Vim reports the change if more than one line is indented (unless 'report'
	    " is 0). 
	    if l:modifiedLineCnt > (&report == 0 ? 0 : 1)
		echo printf('Transformed %d line%s', l:modifiedLineCnt, (l:modifiedLineCnt == 1 ? '' : 's'))
	    endif
	else
	    let v:errmsg = 'Nothing transformed'
	    echohl ErrorMsg
	    echomsg v:errmsg
	    echohl None
	endif
    catch /^Vim\%((\a\+)\)\=:E/
	" v:exception contains what is normally in v:errmsg, but with extra
	" exception source info prepended, which we cut away. 
	let v:errmsg = substitute(v:exception, '^Vim\%((\a\+)\)\=:', '', '')
	echohl ErrorMsg
	echomsg v:errmsg
	echohl None
    catch
	let v:errmsg = 'TextTransform: ' . v:exception
	echohl ErrorMsg
	echomsg v:errmsg
	echohl None
    endtry
endfunction
"TODO function! s:TransformCommandWholeText( firstLine, lastLine, algorithm )
function! TextTransform#MakeCommand( commandOptions, commandName, algorithm, ... )
    let l:options = (a:0 ? a:1 : {})
    execute printf('command -bar %s %s %s call <SID>TransformCommand%s(<line1>, <line2>, %s)',
    \	a:commandOptions,
    \	(a:commandOptions =~# '\%(^\|\s\)-range\%(=\|\s\)' ? '' : '-range'),
    \	a:commandName,
    \	(get(l:options, 'isProcessEntireText', 0) ? 'WholeText' : 'Linewise'),
    \	string(a:algorithm)
    \)
endfunction

"TODO: Command variant that uses s:Transform() and allows to operate on text
" objects, motions, visual selection, ...
"function! TextTransform#MakeCommand( commandOptions, commandName, algorithm, ... )

" vim: set sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
