" Test error beep due to no selection. 

call TextTransform#MakeMappings('', '<Leader>sU', 'MyTransform', "i'")
source helpers/hookIntoError.vim


let g:teststep = 'outside of single quotes'
call InsertExampleText(g:teststep)
normal $\sUU

let g:teststep = 'empty single quotes'
call InsertExampleText(g:teststep)
normal! 0di'
normal \sUU

let g:teststep = 'empty line'
call InsertExampleText(g:teststep)
normal! dd
normal \sUU


call vimtest#SaveOut()
call vimtest#Quit()
