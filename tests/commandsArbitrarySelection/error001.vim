" Test error message due to no selection.

call TextTransform#MakeSelectionCommand('', 'TransformIt', 'MyTransform', "i'")

call vimtest#StartTap()
call vimtap#Plan(3)


let g:teststep = 'outside of single quotes'
call InsertExampleText(g:teststep)
normal! $
try
    TransformIt
    call vimtap#Fail('expected error when ' . g:teststep)
catch
    call vimtap#err#Thrown('Not applicable here', 'Not applicable error shown')
endtry

let g:teststep = 'empty single quotes'
call InsertExampleText(g:teststep)
normal! 0di'
try
    TransformIt
    call vimtap#Fail('expected error when ' . g:teststep)
catch
    call vimtap#err#Thrown('Not applicable here', 'Not applicable error shown')
endtry

let g:teststep = 'empty line'
call InsertExampleText(g:teststep)
normal! dd
try
    TransformIt
    call vimtap#Fail('expected error when ' . g:teststep)
catch
    call vimtap#err#Thrown('Not applicable here', 'Not applicable error shown')
endtry


call vimtest#SaveOut()
call vimtest#Quit()
