" Test the default register contents during algorithm.

call TextTransform#MakeMappings('', '<Leader>sU', 'RegisterCheckTransform')

call vimtest#StartTap()
call vimtap#Plan(6)

let g:registerContents = "#original$Contents%\n^^^&&&\n"

call InsertExampleText('character motion', 1)
call setreg('', g:registerContents)
let g:context = {'description': 'character motion', 'regContents': g:registerContents, 'regType': 'V'}
normal \sU$

call InsertExampleText('single line', 1)
call setreg('', g:registerContents)
let g:context = {'description': 'single line', 'regContents': g:registerContents, 'regType': 'V'}
normal \sUU

call InsertExampleText('blockwise', 3)
call setreg('', g:registerContents)
let g:context = {'description': 'blockwise', 'regContents': g:registerContents, 'regType': 'V'}
execute "normal \<C-v>2ej\\sU"

call vimtest#Quit()
