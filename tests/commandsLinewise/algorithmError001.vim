" Test a transform command with an error in the algorithm.

call TextTransform#MakeCommand('', 'TransformIt', 'BadTransform')


let g:teststep = 'all lines'
call InsertExampleMultilineText(g:teststep)
normal! gg$
try
    2,4TransformIt
    call vimtap#Fail('expected error when ' . g:teststep)
catch
    call vimtap#err#Thrown("TextTransform: This won't work", 'Algorithm error shown')
endtry
normal! i#


call vimtest#SaveOut()
call vimtest#Quit()
