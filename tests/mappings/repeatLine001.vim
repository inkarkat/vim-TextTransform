" Test line mapping repetition with repeat.vim features. 

call vimtest#SkipAndQuitIf(! vimtest#features#SupportsNormalWithCount(), 'Need support for :normal with count')

call TextTransform#MakeMappings('', '<Leader>sU', 'MyTransform')


call InsertExampleText('single line', 3)
normal \sUU
normal j03W.

" Tests that the original count of 2 is repeated, too. 
call InsertExampleText('multiple lines', 6)
normal 2\sUU
normal 3j03W.

" Tests that the original count of 2 is overridden with 3. 
call InsertExampleText('line multiplied', 7)
normal 2\sUU
normal 3j03W3.


call vimtest#SaveOut()
call vimtest#Quit()
