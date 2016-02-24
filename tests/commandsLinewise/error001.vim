" Test error on no transformation.
" Tests that the cursor position is kept.

call TextTransform#MakeCommand('', 'TransformIt', 'NoTransform')

call vimtest#StartTap()
call vimtap#Plan(1)

let g:teststep = 'many lines'
call InsertExampleMultilineText(g:teststep)
normal! gg$
call vimtap#err#Errors('Nothing transformed', '2,4TransformIt', 'Nothing transformed error shown')
normal! i#

call vimtest#SaveOut()
call vimtest#Quit()
