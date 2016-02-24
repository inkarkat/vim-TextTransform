" Test line mapping repetition in visual mode with visualrepeat.vim features. 

call TextTransform#MakeMappings('', '<Leader>sU', 'MyTransform')

runtime plugin/visualrepeat.vim


call InsertExampleText('characterwise repeat', 2)
normal \sUU
normal j06Wve.

call InsertExampleText('linewise repeat', 4)
normal \sUU
normal jVj.

call InsertExampleText('blockwise repeat', 3)
normal \sUU
execute "normal j06W\<C-v>ej."


call vimtest#SaveOut()
call vimtest#Quit()
