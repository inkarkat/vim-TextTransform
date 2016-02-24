" Test change marks set by transform command. 
" Tests that the marks are always set to the entire range, regardless of what
" was transformed, to be consistent with Vim behavior and the TextTransform
" mappings. 

call TextTransform#MakeCommand('', 'TransformIt', 'MyTransform')
call TextTransform#MakeCommand('', 'TransformThe', 'TheTransform')

function! ShowMarks()
    let l:startMark = getpos("'[")
    let l:endMark = getpos("']")

    normal! r#
    call setpos('.', l:startMark)
    normal! r^
    call setpos('.', l:endMark)
    normal! r$
endfunction

call InsertExampleMultilineText('full transform')
normal! gg$
2,4TransformIt
call ShowMarks()

call InsertExampleMultilineText('partial transform')
normal! gg$
2,4TransformThe
call ShowMarks()


call vimtest#SaveOut()
call vimtest#Quit()
