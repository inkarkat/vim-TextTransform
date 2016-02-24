" Test visual mapping N repetition with visualrepeat.vim features. 
" Tests that the count does NOT affect the repetition, as this cannot be done. 

call TextTransform#MakeMappings('', '<Leader>sU', 'MyTransform')

runtime plugin/visualrepeat.vim


call InsertExampleText('characterwise', 3)
normal v2e\sU
normal j06W3.

call InsertExampleText('linewise', 6)
normal V\sU
normal 2j03W3.

call InsertExampleText('blockwise', 6)
execute "normal \<C-v>2ej\\sU"
normal 3j06W3.


call vimtest#SaveOut()
call vimtest#Quit()
