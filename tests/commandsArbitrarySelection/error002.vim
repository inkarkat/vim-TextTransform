" Test error message due to no transformation.

call TextTransform#MakeSelectionCommand('', 'TransformIt', 'NoTransform', 'lines')

call vimtest#StartTap()
call vimtap#Plan(2)


let g:teststep = 'single line'
call InsertExampleMultilineText(g:teststep)
call vimtap#err#Errors('Nothing transformed', 'TransformIt', 'Nothing transformed error shown')

let g:teststep = 'visual characterwise selection'
call InsertExampleMultilineText(g:teststep)
call vimtap#err#Errors('Nothing transformed', 'execute "normal! v3e:TransformIt\<CR>"', 'Nothing transformed error shown')


call vimtest#SaveOut()
call vimtest#Quit()
