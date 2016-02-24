" Test final cursor position after multi-line mapping.

call vimtest#SkipAndQuitIf(! vimtest#features#SupportsNormalWithCount(), 'Need support for :normal with count')

call TextTransform#MakeMappings('', '<Leader>sU', 'MyTransform')


call InsertExampleMultilineText('multiple lines')
normal 2\sUU
normal! r*


call vimtest#SaveOut()
call vimtest#Quit()
