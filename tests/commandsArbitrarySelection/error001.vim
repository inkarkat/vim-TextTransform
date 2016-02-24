" Test error message due to no selection.

call TextTransform#MakeSelectionCommand('', 'TransformIt', 'MyTransform', "i'")

call vimtest#StartTap()
call vimtap#Plan(3)


let g:teststep = 'outside of single quotes'
call InsertExampleText(g:teststep)
normal! $
call vimtap#err#Errors('Not applicable here', 'TransformIt', 'Not applicable error shown')

let g:teststep = 'empty single quotes'
call InsertExampleText(g:teststep)
normal! 0di'
call vimtap#err#Errors('Not applicable here', 'TransformIt', 'Not applicable error shown')

let g:teststep = 'empty line'
call InsertExampleText(g:teststep)
normal! dd
call vimtap#err#Errors('Not applicable here', 'TransformIt', 'Not applicable error shown')


call vimtest#SaveOut()
call vimtest#Quit()
