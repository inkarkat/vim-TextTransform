" Test visual mapping repetition with visualrepeat.vim features. 

call TextTransform#MakeMappings('', '<Leader>sU', 'MyTransform')

runtime plugin/visualrepeat.vim


call InsertExampleText('characterwise', 3)
normal v2e\sU
normal j03W.
normal j06W.

call InsertExampleText('linewise', 6)
normal Vj\sU
normal 3j03W.

call InsertExampleText('blockwise', 9)
execute "normal \<C-v>2ej\\sU"
normal 3j03W.
normal 3j06W.


call vimtest#SaveOut()
call vimtest#Quit()
