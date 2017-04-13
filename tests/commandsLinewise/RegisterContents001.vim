" Test the default register contents during algorithm.

call TextTransform#MakeCommand('', 'TransformIt', 'RegisterCheckTransform')

call vimtest#StartTap()
call vimtap#Plan(2)

let g:registerContents = "#original$Contents%\n^^^&&&\n"

call InsertExampleText('all text', 1)
call setreg('', g:registerContents)
let g:context = {'description': 'all text', 'regContents': g:registerContents, 'regType': 'V'}
TransformIt

call vimtest#Quit()
