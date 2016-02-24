" Test a transform command with an error in the algorithm.

call TextTransform#MakeCommand('', 'TransformIt', 'BadTransform')


let g:teststep = 'all lines'
call InsertExampleMultilineText(g:teststep)
normal! gg$
call vimtap#err#Errors("TextTransform: This won't work", '2,4TransformIt', 'Algorithm error shown')
normal! i#


call vimtest#SaveOut()
call vimtest#Quit()
