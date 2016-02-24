" Test error beep due to no transformation. 

call TextTransform#MakeMappings('', '<Leader>sU', 'NoTransform')
source helpers/hookIntoError.vim


let g:teststep = 'single line'
call InsertExampleMultilineText(g:teststep)
normal \sUU

let g:teststep = 'visual characterwise selection'
call InsertExampleMultilineText(g:teststep)
normal v3e\sU


call vimtest#SaveOut()
call vimtest#Quit()
