" TextTransform.vim: Create text transformation mappings and commands. 
"
" DEPENDENCIES:
"   - vimscript #2136 repeat.vim autoload script (optional). 
"   - visualrepeat.vim autoload script (optional). 
"
" Copyright: (C) 2011 Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'. 
"   Idea, design and implementation based on unimpaired.vim (vimscript #1590)
"   by Tim Pope. 
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>
"
" REVISION	DATE		REMARKS 
"	003	13-Jun-2011	FIX: Directly ring the bell to avoid problems
"				when running under :silent!. 
"	002	05-Apr-2011	Implement TextTransform#Arbitrary#Command(). 
"	001	05-Apr-2011	file creation from autoload/TextTransform.vim. 

function! s:Error( onError, errorText )
    if a:onError ==# 'beep'
	execute "normal! \<C-\>\<C-n>\<Esc>"
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
function! s:Transform( count, algorithm, selectionModes, onError )
    let l:save_view = winsaveview()
    let l:save_cursor = getpos('.')
    let l:save_clipboard = &clipboard
    set clipboard= " Avoid clobbering the selection and clipboard registers. 
    let l:save_reg = getreg('"')
    let l:save_regmode = getregtype('"')
    let @" = ''
    let l:isSuccess = 0
    let l:count = (a:count ? a:count : '')

    let l:selectionModes = type(a:selectionModes) == type([]) ? a:selectionModes : [a:selectionModes]
    for l:SelectionMode in l:selectionModes
	let l:isTextObject = 0
	if type(l:SelectionMode) == type(function('tr'))
	    if call(l:SelectionMode, [])
"****D echomsg '****' string(getpos("'<")) string(getpos("'>"))
		silent! normal! gvy
	    endif
	elseif l:SelectionMode ==# 'lines'
	    silent! execute 'normal! 0v' . l:count . '$' . (&selection ==# 'exclusive' ? '' : 'h') . 'y'
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
	    silent! execute 'normal y' . l:count . l:SelectionMode
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
		silent execute 'normal "_d' . l:count . l:SelectionMode
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

function! TextTransform#Arbitrary#Expression( algorithm, repeatMapping )
    let s:algorithm = a:algorithm
    let s:repeatMapping = a:repeatMapping
    let &opfunc = 'TextTransform#Arbitrary#Opfunc'
    return 'g@'
endfunction

function! TextTransform#Arbitrary#Opfunc( selectionMode )
    let l:count = v:count1
    if s:Transform(v:count, s:algorithm, a:selectionMode, 'beep')
	" This mapping repeats naturally, because it just sets global things,
	" and Vim is able to repeat the g@ on its own. 
	" But enable a repetition in visual mode through visualrepeat.vim. 
	silent! call visualrepeat#set("\<Plug>" . s:repeatMapping . 'Visual', l:count)
    endif
endfunction

function! TextTransform#Arbitrary#Line( algorithm, selectionModes, repeatMapping )
    let l:count = v:count1
    if s:Transform(v:count, a:algorithm, a:selectionModes, 'beep')
	" This mapping needs repeat.vim to be repeatable, because it contains of
	" multiple steps (visual selection, "gv" and "p" commands inside
	" s:Transform()). 
	silent! call repeat#set("\<Plug>" . a:repeatMapping . 'Line', l:count)
	" Also enable a repetition in visual mode through visualrepeat.vim. 
	silent! call visualrepeat#set_also("\<Plug>" . a:repeatMapping . 'Visual', l:count)
    endif
endfunction

function! TextTransform#Arbitrary#Visual( algorithm, repeatMapping )
    let l:count = v:count1
    if s:Transform(v:count, a:algorithm, visualmode(), 'beep')
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

function! TextTransform#Arbitrary#Command( firstLine, lastLine, count, algorithm, selectionModes )
    let l:selectionMode = a:selectionModes
    if a:firstLine == line("'<") && a:lastLine == line("'>")
	let l:selectionMode = visualmode()
    endif

    call s:Transform(a:count, a:algorithm, l:selectionMode, 'errmsg')
endfunction

" vim: set sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
