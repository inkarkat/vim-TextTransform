" Test the default register contents during algorithm.

call TextTransform#MakeSelectionCommand('', 'TransformIt', 'RegisterCheckTransform', 'aw')

call vimtest#StartTap()
call vimtap#Plan(2)

let g:registerContents = "#original$Contents%\n^^^&&&\n"

call InsertExampleText('single text object', 1)
call setreg('', g:registerContents)
let g:context = {'description': 'single text object', 'regContents': g:registerContents, 'regType': 'V'}
TransformIt

call vimtest#Quit()
