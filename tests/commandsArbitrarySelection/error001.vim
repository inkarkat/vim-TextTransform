" Test error message due to no selection. 

call TextTransform#MakeSelectionCommand('', 'TransformIt', 'MyTransform', "i'")


let g:teststep = 'outside of single quotes'
call InsertExampleText(g:teststep)
normal! $
echomsg g:teststep
TransformIt

let g:teststep = 'empty single quotes'
call InsertExampleText(g:teststep)
normal! 0di'
echomsg g:teststep
TransformIt

let g:teststep = 'empty line'
call InsertExampleText(g:teststep)
normal! dd
echomsg g:teststep
TransformIt


call vimtest#SaveOut()
call vimtest#Quit()
