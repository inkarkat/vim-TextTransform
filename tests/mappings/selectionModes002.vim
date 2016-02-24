" Test all built-in selection modes. 

call vimtest#SkipAndQuitIf(! vimtest#features#SupportsNormalWithCount(), 'Need support for :normal with count')

call TextTransform#MakeMappings('', '<Leader>sU', 'MyTransform')


call InsertExampleMultilineText('multiple lines')
normal 2\sUU


call vimtest#SaveOut()
call vimtest#Quit()
