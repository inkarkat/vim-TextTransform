" TextTransform.vim: Text transformations extracted from unimpaired. 
"
" DEPENDENCIES:
"
" Copyright: (C) 2011 Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'. 
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>
"
" REVISION    DATE        REMARKS 
"	    001	    07-Mar-2011	file creation from plugin/unimpaired.vim

function! s:Transform( algorithm, selectionModes, onError )
    let l:save_view = winsaveview()
    let l:save_cursor = getpos('.')
    let l:save_clipboard = &clipboard
    set clipboard= " Avoid clobbering the selection and clipboard registers. 
    let l:save_reg = getreg('"')
    let l:save_regmode = getregtype('"')
    let @@ = ''

    let l:selectionModes = type(a:selectionModes) == type([]) ? a:selectionModes : [a:selectionModes]
    for l:SelectionMode in l:selectionModes
	let l:isTextObject = 0
	if type(l:SelectionMode) == type(function('tr'))
	    if call(l:SelectionMode, [])
"****D echomsg '****' string(getpos("'<")) string(getpos("'>"))
		silent normal! gvy
	    endif
	elseif l:SelectionMode ==# 'lines'
	    silent execute 'normal! 0v' . v:count1 . '$' . (&selection ==# 'exclusive' ? '' : 'h') . 'y'
	elseif l:SelectionMode =~# '^.$'
	    silent execute 'normal! `<' . l:SelectionMode . '`>y'
	elseif l:SelectionMode ==# 'char'
	    silent execute 'normal! `[v`]'. (&selection ==# 'exclusive' ? 'l' : '') . 'y'
	elseif l:SelectionMode ==# 'line'
	    silent execute "normal! '[V']y"
	elseif l:SelectionMode ==# 'block'
	    silent execute "normal! `[\<C-V>`]". (&selection ==# 'exclusive' ? 'l' : '') . 'y'
	else
	    let l:isTextObject = 1
	    silent execute 'normal y' . (v:count ? v:count : '') . l:SelectionMode
	endif
"****D echomsg '****' string(l:SelectionMode) string(@@)
	
	if empty(@@)
	    unlet l:SelectionMode

	    " Reset the cursor; some selection modes depend on it. 
	    call setpos('.', l:save_cursor)

	    continue
	endif

	let l:yankMode = getregtype('"')
	let l:transformedText = {a:algorithm}(@@)
	if l:transformedText ==# @@
	    call winrestview(l:save_view)
	    if a:onError ==# 'beep'
		execute "normal \<Plug>RingTheBell" 
	    elseif a:onError ==# 'errmsg'
		let v:errmsg = 'Nothing transformed'
		echohl ErrorMsg
		echomsg v:errmsg
		echohl None
	    endif
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
		normal! P
	    else
		normal! gvp
	    endif
	endif
	break
    endfor

    call setreg('"', l:save_reg, l:save_regmode)
    let &clipboard = l:save_clipboard

    " silent! call repeat#set("\<Plug>unimpairedLine".a:algorithm,a:selectionModes)
endfunction

function! TextTransform#TransformOpfunc(selectionMode)
    return s:Transform(s:algorithm, a:selectionMode, 'beep')
endfunction

function! s:TransformSetup(algorithm)
    let s:algorithm = a:algorithm
    let &opfunc = 'TextTransform#TransformOpfunc'
endfunction

function! TextTransform#MapTransform(map_options, key, algorithm, ...)
    execute 'nnoremap ' . a:map_options . ' <silent> <Plug>unimpaired'    .a:algorithm.' :<C-U>call <SID>TransformSetup("'.a:algorithm.'")<CR>g@'
    execute 'xnoremap ' . a:map_options . ' <silent> <Plug>unimpaired'    .a:algorithm.' :<C-U>call <SID>Transform("'.a:algorithm.'",visualmode(), "beep")<CR>'

    let LineTypes = a:0 ? a:1 : 'lines'  
    execute 'nnoremap ' . a:map_options . ' <silent> <Plug>unimpairedLine'.a:algorithm.' :<C-U>call <SID>Transform('.string(a:algorithm).','.string(LineTypes).', "beep")<CR>'

    execute 'nmap ' . a:map_options . ' '.a:key.'  <Plug>unimpaired'.a:algorithm
    execute 'xmap ' . a:map_options . ' '.a:key.'  <Plug>unimpaired'.a:algorithm
    let l:doubledKey = matchstr(a:key, '\(<[[:alpha:]-]\+>\|.\)$')
    execute 'nmap ' . a:map_options . ' '.a:key.l:doubledKey.' <Plug>unimpairedLine'.a:algorithm
endfunction

"call TextTransform#MapTransform('<buffer>', '[y', 'StringEncode')
"call TextTransform#MapTransform('<buffer>', ']y', 'StringDecode')

function! TextTransform#MakeCommand( commandOptions, commandName, algorithm )
    " TODO
endfunction

" vim: set sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
