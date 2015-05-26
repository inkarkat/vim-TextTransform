" TextTransform/Lines.vim: Text transformation on lines of text.
"
" This module is responsible for the transformation triggered by commands.
"
" DEPENDENCIES:
"   - TextTransform.vim autoload script
"   - ingo/lines.vim autoload script (for TextTransform#Lines#TransformWholeText())
"   - ingo/range.vim autoload script
"
" Copyright: (C) 2011-2015 Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'.
"   Idea, design and implementation based on unimpaired.vim (vimscript #1590)
"   by Tim Pope.
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>
"
" REVISION	DATE		REMARKS
"   1.25.014	27-May-2015	Handle non-String results returned by the
"				algorithm via TextTransform#ToText().
"				When transforming individual lines and we get
"				multiple lines as the algorithm's result,
"				setline() cannot be used, and the added lines
"				need to be accounted for.
"   1.25.013	03-Feb-2015	FIX: Correctly handle command range of :. when
"				on a closed fold. Need to use
"				ingo#range#NetStart().
"   1.25.012	23-Sep-2014	Minor: Remove debugging output when a command
"				transforms whole lines.
"   1.24.011	13-Jun-2014	ENH: Add g:TextTransformContext.isBang (for
"				custom transformation commands).
"   1.23.010	19-May-2014	Refactoring: Use ingo#lines#Replace().
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
function! s:Transform( startLnum, endLnum, text, algorithm, isRepeat, arguments, isBang )
    let g:TextTransformContext = {
    \   'mapMode': 'c',
    \   'mode': 'V',
    \   'startPos': [0, a:startLnum, 1, 0],
    \   'endPos': [0, a:endLnum, 0x7FFFFFFF, 0],
    \   'arguments': a:arguments,
    \   'isBang': a:isBang,
    \   'isAlgorithmRepeat': (type(s:previousAlgorithm) == type(a:algorithm) && s:previousAlgorithm ==# a:algorithm),
    \   'isRepeat': a:isRepeat
    \}
    try
	return TextTransform#ToText(call(a:algorithm, [a:text]))
    finally
	unlet g:TextTransformContext
    endtry
endfunction
function! TextTransform#Lines#TransformLinewise( startLnum, endLnum, isBang, algorithm, ... )
    let [l:lastModifiedLine, l:modifiedLineCnt] = [0, 0]

    for l:i in range(a:startLnum, a:endLnum)
	let l:text = getline(l:i)
	let l:transformedText = s:Transform(l:i, l:i, l:text, a:algorithm, (l:i != a:startLnum), a:000, a:isBang)
	if l:text !=# l:transformedText
	    if l:transformedText =~# '\n'
		" We got multiple lines, cannot use setline(), as that will
		" _replace_ following lines.
		let l:lineNum = line('$')
		    call ingo#lines#Replace(line('.'), line('.'), l:transformedText)  " ingo#lines#Replace() can take multi-line results as a newline-delimited String.
		let l:addedLineNum = line('$') - l:lineNum
		let l:lastModifiedLine = l:i + l:addedLineNum
		let l:modifiedLineCnt += 1 + l:addedLineNum
	    else
		let l:lastModifiedLine = l:i
		let l:modifiedLineCnt += 1
		call setline(l:i, l:transformedText)
	    endif
	endif
    endfor

    return [l:lastModifiedLine, l:modifiedLineCnt]
endfunction
function! TextTransform#Lines#TransformWholeText( startLnum, endLnum, isBang, algorithm, ... )
    let [l:lastModifiedLine, l:modifiedLineCnt] = [0, 0]

    let l:lines = getline(a:startLnum, a:endLnum)
    let l:text = join(l:lines, "\n")
    let l:transformedText = s:Transform(a:startLnum, a:endLnum, l:text, a:algorithm, 0, a:000, a:isBang)
    if l:text !=# l:transformedText
	let l:lineNum = line('$')
	    call ingo#lines#Replace(a:startLnum, a:endLnum, l:transformedText)  " ingo#lines#Replace() can take multi-line results as a newline-delimited String.
	let l:addedLineNum = line('$') - l:lineNum
	let l:modifiedLineCnt += l:addedLineNum

	" In this process function, we don't get the modification data for free,
	" we have to generate the data ourselves. Fortunately, we still have to
	" original lines to compare with the changed buffer.
	for l:i in range(a:startLnum, a:endLnum)
	    if getline(l:i) !=# l:lines[l:i - a:startLnum]
		let l:lastModifiedLine = l:i + l:addedLineNum
		let l:modifiedLineCnt += 1
	    endif
	endfor
    endif
"****D echomsg '****' string( [l:lastModifiedLine, l:modifiedLineCnt])
    return [l:lastModifiedLine, l:modifiedLineCnt]
endfunction
function! TextTransform#Lines#TransformCommand( startLnum, endLnum, isBang, algorithm, ProcessFunction, ... )
    let [l:startLnum, l:endLnum] = [ingo#range#NetStart(a:startLnum), ingo#range#NetEnd(a:endLnum)]
    try
	let [l:lastModifiedLine, l:modifiedLineCnt] = call(a:ProcessFunction, [l:startLnum, l:endLnum, a:isBang, a:algorithm] + a:000)

	unlet! s:previousAlgorithm | let s:previousAlgorithm = a:algorithm

	if l:modifiedLineCnt > 0
	    " Set change marks to the first columns of the range, like
	    " :substitute does.
	    call setpos("'[", [0, l:startLnum, 1, 0])
	    call setpos("']", [0, l:endLnum, 1, 0])

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
