" TextTransform/Selections.vim: General-purpose text selections.
"
" DEPENDENCIES:
"
" Copyright: (C) 2011-2014 Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'.
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>
"
" REVISION	DATE		REMARKS
"   1.22.002	06-Mar-2014	Add to TextTransform plugin.
"	001	08-Mar-2011	file creation

function! TextTransform#Selections#SurroundedByCharsInSingleLine( chars )
    " Cursor must be inside (not on!) one of the characters in a:chars.
    let l:surroundPattern = '^.*\zs\([' . a:chars . ']\)\%(\1\@!.\)\{-}\%#\%(\1\@!.\)\{1,}\1\ze.*$'

    let l:save_cursor = getpos('.')
    if search(l:surroundPattern, 'b', line('.'))	" Beginning of surrounded text.
	" Start characterwise visual mode _inside_ the surrounds.
	normal! lv
	if search(l:surroundPattern, 'e', line('.')) " End of surrounded text.
	    " Note: Need to leave visual mode to enable 'gv' to re-select the
	    " current selection.
	    execute 'normal! ' . (&selection ==# 'exclusive' ? '' : 'h') . "\<Esc>"
	    return 1
	else
	    " Undo visual mode and backwards search.
	    execute "normal! \<Esc>"
	    call setpos('.', l:save_cursor)
	endif
    endif
    return 0
endfunction

function! TextTransform#Selections#QuotedInSingleLine()
    return TextTransform#Selections#SurroundedByCharsInSingleLine('''"')
endfunction

" vim: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
