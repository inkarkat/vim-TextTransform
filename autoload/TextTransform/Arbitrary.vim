" TextTransform/Arbitrary.vim: Text transformation on any text selection.
"
" This module is responsible for the transformation triggered by mappings.
"
" DEPENDENCIES:
"   - TextTransform.vim autoload script
"   - ingo/compat.vim autoload script
"   - ingo/err.vim autoload script
"   - ingo/list.vim autoload script
"   - ingo/msg.vim autoload script
"   - ingo/selection/frompattern.vim autoload script
"   - repeat.vim (vimscript #2136) autoload script (optional)
"   - visualrepeat.vim (vimscript #3848) autoload script (optional)
"
" Copyright: (C) 2011-2015 Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'.
"   Idea, design and implementation based on unimpaired.vim (vimscript #1590)
"   by Tim Pope.
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>
"
" REVISION	DATE		REMARKS
"   1.25.022	27-May-2015	Handle non-String results returned by the
"				algorithm via TextTransform#ToText().
"   1.24.021	13-Jun-2014	ENH: Add g:TextTransformContext.isBang (for
"				custom transformation commands).
"   1.23.020	08-May-2014	ENH: Support selection mode "/{pattern}/", which
"				selects the text region under / after the cursor
"				that matches {pattern}.
"   1.23.019	25-Mar-2014	Minor: Also handle :echoerr in the algorithm.
"   1.21.018	20-Nov-2013	Need to use ingo#compat#setpos() to make a
"				selection in Vim versions before 7.3.590.
"   1.21.017	15-Oct-2013	Replace conditional with ingo#list#Make().
"   1.20.016	25-Sep-2013	Add g:TextTransformContext.arguments.
"   1.20.015	16-Sep-2013	Add g:TextTransformContext.isAlgorithmRepeat.
"				Add g:TextTransformContext.isRepeat. For that,
"				we need to provide additional <Plug>TextR...
"				repeat mappings installed into repeat.vim. For
"				the operator mapping, its g@ is repeated by Vim
"				itself, but not the
"				TextTransform#Arbitrary#Expression() triggered
"				by the mapping, so we clear the repeatTick there
"				to be able to distinguish.
"   1.20.014	24-Jul-2013	Add g:TextTransformContext.mapMode.
"   1.12.013	26-Jun-2013	Use ingo/err.vim for commands; mappings use its
"				infrastructure, but still :echomsg the error
"				message (or beep).
"   1.12.012	25-Jun-2013	FIX: When the selection mode is a text object,
"				and the text is at the end of the line, the
"				replacement is inserted one-off to the left.
"				Temporarily :set virtualedit=onemore to ensure
"				that the "P" paste is done at the right position
"				in all cases.
"   1.11.011	17-May-2013	FIX: When the selection mode is a text object,
"				must still establish a visual selection of the
"				yanked text so that g:TextTransformContext
"				contains valid data for use by a:algorithm.
"				Use ingo-library for error messages.
"   1.11.010	21-Mar-2013	Avoid changing the jumplist.
"   1.10.009	18-Jan-2013	FIX: In a blockwise visual selection with $ to
"				the end of the lines, only the square block from
"				'< to '> is transformed. Need to yank the
"				selection with gvy instead of defining a new
"				selection with the marks, a mistake inherited
"				from the original unimpaired.vim implementation.
"				Save and restore the original visual area to
"				avoid clobbering the '< and '> marks and gv by
"				line- and motion mappings.
"				Temporarily set g:TextTransformContext to the
"				begin and end of the currently transformed area
"				to offer an extended interface to algorithms.
"   1.03.008	28-Aug-2012	For the custom operators, handle readonly and
"				nomodifiable buffers by printing just the
"				warning / error, without the multi-line function
"				error.
"   1.02.007	28-Jul-2012	Avoid E706: Variable type mismatch when
"				TextTransform#Arbitrary#Expression() is used
"				with both Funcref- and String-type algorithms.
"   1.01.006	05-Apr-2012	Place the cursor at the beginning of the
"				transformed text, to be consistent with built-in
"				transformation commands like gU, and because it
"				makes much more sense.
"   1.00.005	05-Apr-2012	Initial release.
"	005	14-Mar-2012	Always set repetition, not just when the
"				transformation succeeds, so that the repetition
"				does not unset itself when a repeat attempt
"				fails. This trades one inconsistency for
"				another: The initial mapping should not repeat
"				when the transformation fails. We could achieve
"				that for the line and visual mappings, although
"				clumsily. (We need to pass a:isRepeat to the
"				functions here; either we set up a duplicate set
"				of Repeat <Plug>-mappings, or we try to detect
"				the repetition at the beginning of the
"				<Plug>-mapping (in s:Before(), comparing
"				b:changedtick with g:repeat_tick, which caused
"				funny errors when I tried it), and then pass
"				this information to the later call via a
"				script-local variable.) This cannot be achieved
"				for the operator-pending mapping, because Vim
"				will always repeat the g@ command; there's no
"				way to undo that. Therefore, rather be
"				internally consistent and avoid the large
"				complexity of a partial solution (which other
"				repeat.vim plugins also do not attempt.)
"	004	06-Dec-2011	Retire visualrepeat#set_also(); use
"				visualrepeat#set() everywhere.
"	003	13-Jun-2011	FIX: Directly ring the bell to avoid problems
"				when running under :silent!.
"	002	05-Apr-2011	Implement TextTransform#Arbitrary#Command().
"	001	05-Apr-2011	file creation from autoload/TextTransform.vim.
let s:save_cpo = &cpo
set cpo&vim

let s:repeatTick = -1
let s:previousTransform = {'changedtick': -1, 'algorithm': ''}
function! s:Error( onError, errorText )
    if a:onError ==# 'beep'
	execute "normal! \<C-\>\<C-n>\<Esc>"
    elseif a:onError ==# 'errmsg'
	call ingo#err#Set(a:errorText)
    endif
endfunction
function! s:ApplyAlgorithm( algorithm, text, mapMode, changedtick, arguments, isBang )
    let l:isAlgorithmRepeat = (s:previousTransform.changedtick == a:changedtick &&
    \   type(s:previousTransform.algorithm) == type(a:algorithm) && s:previousTransform.algorithm ==# a:algorithm
    \)
    let g:TextTransformContext = {
    \   'mapMode': a:mapMode,
    \   'mode': visualmode(),
    \   'startPos': getpos("'<"),
    \   'endPos': getpos("'>"),
    \   'arguments': a:arguments,
    \   'isBang': a:isBang,
    \   'isAlgorithmRepeat': l:isAlgorithmRepeat,
    \   'isRepeat': (l:isAlgorithmRepeat && s:repeatTick == a:changedtick)
    \}
    try
	return [1, TextTransform#ToText(call(a:algorithm, [a:text]))]
    catch /^Vim\%((\a\+)\)\=:/
	call ingo#err#SetVimException()
	return [0, '']
    catch
	call ingo#err#Set('TextTransform: ' . v:exception)
	return [0, '']
    finally
	unlet g:TextTransformContext
    endtry
endfunction
function! s:Transform( count, algorithm, selectionModes, onError, mapMode, changedtick, arguments, isBang )
    let l:save_view = winsaveview()
    let l:save_cursor = getpos('.')
    let l:save_clipboard = &clipboard
    set clipboard= " Avoid clobbering the selection and clipboard registers.
    let l:save_reg = getreg('"')
    let l:save_regmode = getregtype('"')
    let @" = ''
    let l:save_visualarea = [visualmode(), getpos("'<"), getpos("'>")]
    let l:isSuccess = 0
    let l:count = (a:count ? a:count : '')
    call ingo#err#Clear()

    for l:SelectionMode in ingo#list#Make(a:selectionModes)
	let l:isTextObject = 0
	if type(l:SelectionMode) == type(function('tr'))
	    if call(l:SelectionMode, [])
"****D echomsg '****' string(getpos("'<")) string(getpos("'>"))
		silent! normal! gvy
	    endif
	elseif l:SelectionMode ==# 'lines'
	    silent! execute 'normal! 0v' . l:count . '$' . (&selection ==# 'exclusive' ? '' : 'h') . 'y'
	elseif l:SelectionMode =~# "^[vV\<C-v>]$"
	    silent! normal! gvy
	elseif l:SelectionMode ==# 'char'
	    silent! execute 'normal! g`[vg`]'. (&selection ==# 'exclusive' ? 'l' : '') . 'y'
	elseif l:SelectionMode ==# 'line'
	    silent! execute "normal! g'[Vg']y"
	elseif l:SelectionMode ==# 'block'
	    silent! execute "normal! g`[\<C-V>g`]". (&selection ==# 'exclusive' ? 'l' : '') . 'y'
	elseif l:SelectionMode =~# '^/.*/$'
	    if ! ingo#selection#frompattern#Select('v', l:SelectionMode[1:-2], line('.'))
		continue
	    endif
	    silent! normal! gvy
	else
	    let l:isTextObject = 1
	    silent! execute 'normal y' . l:count . l:SelectionMode

	    " Note: After (successfully) yanking the text object, still
	    " establish a visual selection of the yanked text;
	    " s:ApplyAlgorithm() uses the visual selection to establish the
	    " g:TextTransformContext for use by a:algorithm.
	    if ! empty(@")
		silent! execute 'normal! g`[vg`]'. (&selection ==# 'exclusive' ? 'l' : '') . "\<Esc>"
	    endif
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
	let [l:isSuccess, l:transformedText] = s:ApplyAlgorithm(a:algorithm, @", a:mapMode, a:changedtick, a:arguments, a:isBang)
	if ! l:isSuccess
	    call winrestview(l:save_view)
	    if a:onError ==# 'beep'
		" s:ApplyAlgorithm() has already submitted the error, but for
		" mappings, we also want them to beep.
		call s:Error(a:onError, '')
	    endif
	elseif l:transformedText ==# @"
	    call winrestview(l:save_view)
	    let l:isSuccess = 0
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
		" When the text object works on text at the end of the line, the
		" pasting with "P" is one off; "p" would need to be used. Since
		" this situation is hard to detect, we don't want to apply the
		" text object to a visual selection (a custom one may behave
		" different there or even not be defined), and using "s$<Esc>"
		" instead of "d" would clobber register "., we avoid this
		" problematic behavior by temporarily changing 'virtualedit' to
		" keep the cursor one past the end.
		let l:save_virtualedit = &virtualedit
		set virtualedit=onemore
		    silent execute 'normal "_d' . l:count . l:SelectionMode
		    " The paste command leaves the cursor at the end of the
		    " pasted text, but the behavior of built-in transformations
		    " is to place the cursor at the beginning of the transformed
		    " text. The g`[ does this for us.
		    silent normal! Pg`[
		let &virtualedit = l:save_virtualedit
	    else
		silent normal! gvpg`[
	    endif
	endif
    endif

    if visualmode() !=# l:save_visualarea[0]
	execute 'normal!' l:save_visualarea[0] . "\<Esc>"
    endif
    call ingo#compat#setpos("'<", l:save_visualarea[1])
    call ingo#compat#setpos("'>", l:save_visualarea[2])

    call setreg('"', l:save_reg, l:save_regmode)
    let &clipboard = l:save_clipboard

    return l:isSuccess
endfunction

function! TextTransform#Arbitrary#Expression( algorithm, repeatMapping )
    unlet! s:algorithm  " The algorithm can be a Funcref or String; avoid E706: Variable type mismatch.
    let s:algorithm = a:algorithm
    let s:repeatMapping = a:repeatMapping
    let s:repeatTick = -1
    set opfunc=TextTransform#Arbitrary#Opfunc

    let l:keys = 'g@'

    if ! &l:modifiable || &l:readonly
	" Probe for "Cannot make changes" error and readonly warning via a no-op
	" dummy modification.
	" In the case of a nomodifiable buffer, Vim will abort the normal mode
	" command chain, discard the g@, and thus not invoke the operatorfunc.
	let l:keys = ":call setline('.', getline('.'))\<CR>" . l:keys
    endif

    return l:keys
endfunction

function! TextTransform#Arbitrary#Opfunc( selectionMode )
    let l:count = v:count1
    if ! s:Transform(v:count, s:algorithm, a:selectionMode, 'beep', 'o', b:changedtick - (&l:readonly ? 1 : 0), [], 0) " Need to subtract 1 from b:changedtick because of the no-op modification check (which here is conditional on 'readonly').
	if ingo#err#IsSet()
	    call ingo#msg#ErrorMsg(ingo#err#Get())
	endif
    endif

    " This mapping repeats naturally, because it just sets global things,
    " and Vim is able to repeat the g@ on its own.
    " But enable a repetition in visual mode through visualrepeat.vim.
    silent! call visualrepeat#set("\<Plug>" . s:repeatMapping . 'Visual', l:count)
    " Store the change number and algorithm so that we can detect a repeat of
    " the same substitution.
    let s:previousTransform = {'changedtick': b:changedtick, 'algorithm': s:algorithm}
    let s:repeatTick = b:changedtick
endfunction

function! TextTransform#Arbitrary#Line( algorithm, selectionModes, repeatMapping, isRepeat )
    let l:count = v:count1
    if ! a:isRepeat | let s:repeatTick = -1 | endif
    if ! s:Transform(v:count, a:algorithm, a:selectionModes, 'beep', 'n', b:changedtick - 1, [], 0)    " Need to subtract 1 from b:changedtick because of the no-op modification check.
	if ingo#err#IsSet()
	    call ingo#msg#ErrorMsg(ingo#err#Get())
	endif
    endif

    " This mapping needs repeat.vim to be repeatable, because it contains of
    " multiple steps (visual selection, "gv" and "p" commands inside
    " s:Transform()).
    silent! call       repeat#set("\<Plug>" . a:repeatMapping . 'Line', l:count)
    " Also enable a repetition in visual mode through visualrepeat.vim.
    silent! call visualrepeat#set("\<Plug>" . a:repeatMapping . 'Visual', l:count)
    " Store the change number and algorithm so that we can detect a repeat of
    " the same substitution.
    let s:previousTransform = {'changedtick': b:changedtick, 'algorithm': a:algorithm}
    let s:repeatTick = b:changedtick
endfunction

function! TextTransform#Arbitrary#Visual( algorithm, repeatMapping, isRepeat )
    let l:count = v:count1
    if ! a:isRepeat | let s:repeatTick = -1 | endif
    if ! s:Transform(v:count, a:algorithm, visualmode(), 'beep', 'v', b:changedtick - 1, [], 0)    " Need to subtract 1 from b:changedtick because of the no-op modification check.
	if ingo#err#IsSet()
	    call ingo#msg#ErrorMsg(ingo#err#Get())
	endif
    endif

    " Make the visual mode mapping repeatable in normal mode, applying the
    " previous visual mode transformation at the current cursor position, using
    " the size of the last visual selection.
    " Note: We cannot pass the count here, the <SID>Reselect "1v" would swallow
    " that. But what would a count mean in this case, anyway?
    silent! call       repeat#set("\<Plug>" . a:repeatMapping . 'Visual', -1)
    " Also enable a repetition in visual mode through visualrepeat.vim.
    silent! call visualrepeat#set("\<Plug>" . a:repeatMapping . 'Visual', l:count)
    " Store the change number and algorithm so that we can detect a repeat of
    " the same substitution.
    let s:previousTransform = {'changedtick': b:changedtick, 'algorithm': a:algorithm}
    let s:repeatTick = b:changedtick
endfunction

function! TextTransform#Arbitrary#Command( firstLine, lastLine, isBang, count, algorithm, selectionModes, ... )
    let l:selectionMode = a:selectionModes
    if a:firstLine == line("'<") && a:lastLine == line("'>")
	let l:selectionMode = visualmode()
    endif

    let l:status = s:Transform(a:count, a:algorithm, l:selectionMode, 'errmsg', 'c', b:changedtick - 1, a:000, a:isBang)    " Need to subtract 1 from b:changedtick because of the no-op modification check.

    " Store the change number and algorithm so that we can detect a repeat of
    " the same substitution.
    let s:previousTransform = {'changedtick': b:changedtick, 'algorithm': a:algorithm}

    return l:status
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
" vim: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
