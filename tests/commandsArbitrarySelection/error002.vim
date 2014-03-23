" Test error message due to no transformation.

call TextTransform#MakeSelectionCommand('', 'TransformIt', 'NoTransform', 'lines')

call vimtest#StartTap()
call vimtap#Plan(2)


let g:teststep = 'single line'
call InsertExampleMultilineText(g:teststep)
try
    TransformIt
    call vimtap#Fail('expected error when ' . g:teststep)
catch
    call vimtap#err#Thrown('Nothing transformed', 'Nothing transformed error shown')
endtry

let g:teststep = 'visual characterwise selection'
call InsertExampleMultilineText(g:teststep)
try
    execute "normal! v3e:TransformIt\<CR>"
    call vimtap#Fail('expected error when ' . g:teststep)
catch
    call vimtap#err#Thrown('Nothing transformed', 'Nothing transformed error shown')
endtry


call vimtest#SaveOut()
call vimtest#Quit()
