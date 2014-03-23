" Test error on no transformation.
" Tests that the cursor position is kept.

call TextTransform#MakeCommand('', 'TransformIt', 'NoTransform')

call vimtest#StartTap()
call vimtap#Plan(1)

let g:teststep = 'many lines'
call InsertExampleMultilineText(g:teststep)
normal! gg$
try
    2,4TransformIt
    call vimtap#Fail('expected error when ' . g:teststep)
catch
    call vimtap#err#Thrown('Nothing transformed', 'Nothing transformed error shown')
endtry
normal! i#

call vimtest#SaveOut()
call vimtest#Quit()
