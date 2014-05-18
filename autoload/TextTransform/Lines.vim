" TextTransform/Lines.vim: Text transformation on lines of text.
"
" This module is responsible for the transformation triggered by commands.
"
" DEPENDENCIES:
"   - ingo/lines.vim autoload script (for TextTransform#Lines#TransformWholeText())
"
" Copyright: (C) 2011-2014 Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'.
"   Idea, design and implementation based on unimpaired.vim (vimscript #1590)
"   by Tim Pope.
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>
"
" REVISION	DATE		REMARKS
"   1.23.009	25-Mar-2014	Minor: Also handle :echoerr in the algorithm.
"   1.20.008	25-Sep-2013	Add g:TextTransformContext.arguments.
"   1.20.007	16-Sep-2013	Add g:TextTransform.isAlgorithmRepeat and
"				g:TextTransform.isRepeat.
"   1.20.006	24-Jul-2013	Add g:TextTransformContext.mapMode.
"   1.11.005	17-May-2013	Use ingo-library for error messages.
"   1.11.004	04-Apr-2013	Move ingolines#PutWrapper() into ingo-library.
"   1.10.003	18-Jan-2013	Temporarily set g:TextTransformContext to the
"				begin and end of the currently transformed lines
"				to offer the same extended interface for
"				algorithms that TextTransform/Arbitrary.vim
"				had automatically with the '<, '> marks and
"				visualmode().
"   1.03.002	02-Sep-2012	Avoid clobbering the expression register (for
"				commands that use options.isProcessEntireText).
"   1.00.001	05-Apr-2012	Initial release.
"	001	05-Apr-2011	file creation from autoload/TextTransform.vim.
let s:save_cpo = &cpo
set cpo&vim

let s:previousAlgorithm = ''
function! s:Transform( firstLine, lastLine, text, algorithm, isRepeat, arguments )
    let g:TextTransformContext = {
    \   'mapMode': 'c',
    \   'mode': 'V',
    \   'startPos': [0, a:firstLine, 1, 0],
    \   'endPos': [0, a:lastLine, 0x7FFFFFFF, 0],
    \   'arguments': a:arguments,
    \   'isAlgorithmRepeat': (type(s:previousAlgorithm) == type(a:algorithm) && s:previousAlgorithm ==# a:algorithm),
    \   'isRepeat': a:isRepeat
    \}
    try
	return call(a:algorithm, [a:text])
    finally
	unlet g:TextTransformContext
    endtry
endfunction
function! TextTransform#Lines#TransformLinewise( firstLine, lastLine, algorithm, ... )
    let [l:lastModifiedLine, l:modifiedLineCnt] = [0, 0]

    for l:i in range(a:firstLine, a:lastLine)
	let l:text = getline(l:i)
	let l:transformedText = s:Transform(l:i, l:i, l:text, a:algorithm, (l:i != a:firstLine), a:000)
	if l:text !=# l:transformedText
	    let l:lastModifiedLine = l:i
	    let l:modifiedLineCnt += 1
	    call setline(l:i, l:transformedText)
	endif
    endfor

    return [l:lastModifiedLine, l:modifiedLineCnt]
endfunction
function! TextTransform#Lines#TransformWholeText( firstLine, lastLine, algorithm, ... )
    let [l:lastModifiedLine, l:modifiedLineCnt] = [0, 0]

    let l:lines = getline(a:firstLine, a:lastLine)
    let l:text = join(l:lines, "\n")
    let l:transformedText = s:Transform(a:firstLine, a:lastLine, l:text, a:algorithm, 0, a:000)
    if l:text !=# l:transformedText
	silent execute a:firstLine . ',' . a:lastLine . 'delete _'
	silent call ingo#lines#PutWrapper((a:firstLine - 1), 'put', l:transformedText)

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
function! TextTransform#Lines#TransformCommand( firstLine, lastLine, algorithm, ProcessFunction, ... )
    try
	let [l:lastModifiedLine, l:modifiedLineCnt] = call(a:ProcessFunction, [a:firstLine, a:lastLine, a:algorithm] + a:000)

	unlet! s:previousAlgorithm | let s:previousAlgorithm = a:algorithm

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

	    return 1
	else
	    call ingo#err#Set('Nothing transformed')
	    return 0
	endif
    catch /^Vim\%((\a\+)\)\=:/
	call ingo#err#SetVimException()
	return 0
    catch
	call ingo#err#Set('TextTransform: ' . v:exception)
	return 0
    endtry
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
" vim: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
