" Test visual mapping repetition in visual mode with visualrepeat.vim features. 

call TextTransform#MakeMappings('', '<Leader>sU', 'MyTransform')

runtime plugin/visualrepeat.vim


call InsertExampleText('characterwise into linewise', 3)
normal v2e\sU
normal jVj\sU

call InsertExampleText('linewise into linewise', 6)
normal V\sU
normal 2jV2j\sU

call InsertExampleText('linewise into characterwise', 3)
normal Vj\sU
normal 2j06Wv2e.


call vimtest#SaveOut()
call vimtest#Quit()
