" TextTransform/Lines.vim: Text transformation on lines of text.
"
" This module is responsible for the transformation triggered by commands.
"
" DEPENDENCIES:
"   - ingolines.vim autoload script (for
"     TextTransform#Lines#TransformWholeText())
"
" Copyright: (C) 2011-2012 Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'.
"   Idea, design and implementation based on unimpaired.vim (vimscript #1590)
"   by Tim Pope.
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>
"
" REVISION	DATE		REMARKS
"   1.03.002	02-Sep-2012	Avoid clobbering the expression register (for
"				commands that use options.isProcessEntireText).
"   1.00.001	05-Apr-2012	Initial release.
"	001	05-Apr-2011	file creation from autoload/TextTransform.vim.

function! TextTransform#Lines#TransformLinewise( firstLine, lastLine, algorithm )
    let [l:lastModifiedLine, l:modifiedLineCnt] = [0, 0]

    for l:i in range(a:firstLine, a:lastLine)
	let l:text = getline(l:i)
	let l:transformedText = call(a:algorithm, [l:text])
	if l:text !=# l:transformedText
	    let l:lastModifiedLine = l:i
	    let l:modifiedLineCnt += 1
	    call setline(l:i, l:transformedText)
	endif
    endfor

    return [l:lastModifiedLine, l:modifiedLineCnt]
endfunction
function! TextTransform#Lines#TransformWholeText( firstLine, lastLine, algorithm )
    let [l:lastModifiedLine, l:modifiedLineCnt] = [0, 0]

    let l:lines = getline(a:firstLine, a:lastLine)
    let l:text = join(l:lines, "\n")
    let l:transformedText = call(a:algorithm, [l:text])
    if l:text !=# l:transformedText
	silent execute a:firstLine . ',' . a:lastLine . 'delete _'
	call ingolines#PutWrapper((a:firstLine - 1), 'put', l:transformedText)

	" In this process function, we don't get the modification data for free,
	" we have to generate the data ourselves. Fortunately, we still have to
	" original lines to compare with the changed buffer.
	for l:i in range(a:firstLine, a:lastLine)
	    if getline(l:i) !=# l:lines[l:i - a:firstLine]
		let l:lastModifiedLine = l:i
		let l:modifiedLineCnt += 1
	    endif
	endfor
    endif

    echomsg string( [l:lastModifiedLine, l:modifiedLineCnt])
    return [l:lastModifiedLine, l:modifiedLineCnt]
endfunction
function! TextTransform#Lines#TransformCommand( firstLine, lastLine, algorithm, ProcessFunction )
    try
	let [l:lastModifiedLine, l:modifiedLineCnt] = call(a:ProcessFunction, [a:firstLine, a:lastLine, a:algorithm])

	if l:modifiedLineCnt > 0
	    " Set change marks to the first columns of the range, like
	    " :substitute does.
	    call setpos("'[", [0, a:firstLine, 1, 0])
	    call setpos("']", [0, a:lastLine, 1, 0])

	    " Move the cursor to the first non-blank character of the last
	    " modified line, like :substitute does.
	    execute 'normal!' l:lastModifiedLine . 'G^'

	    if l:modifiedLineCnt > &report
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

" vim: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
