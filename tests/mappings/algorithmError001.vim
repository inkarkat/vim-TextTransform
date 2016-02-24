" Test all built-in selection modes with an error in the algorithm. 
" Tests that the error message is printed. 
" Tests that a beep occurs. 

call TextTransform#MakeMappings('', '<Leader>sU', 'BadTransform')
source helpers/hookIntoError.vim


let g:teststep = 'single line'
call InsertExampleMultilineText(g:teststep)
normal \sUU

let g:teststep = 'character motion'
call InsertExampleMultilineText(g:teststep)
normal \sU3e

let g:teststep = 'line motion'
call InsertExampleMultilineText(g:teststep)
normal \sU+

let g:teststep = 'visual characterwise selection'
call InsertExampleMultilineText(g:teststep)
normal v3e\sU

let g:teststep = 'visual linewise selection'
call InsertExampleMultilineText(g:teststep)
normal Vj\sU

let g:teststep = 'visual blockwise selection'
call InsertExampleMultilineText(g:teststep)
execute "normal \<C-V>ej\\sU"


call vimtest#SaveOut()
call vimtest#Quit()
