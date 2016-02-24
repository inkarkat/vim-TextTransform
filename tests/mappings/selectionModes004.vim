" Test text object selection mode. 

call vimtest#SkipAndQuitIf(! vimtest#features#SupportsNormalWithCount(), 'Need support for :normal with count')

call TextTransform#MakeMappings('', '<Leader>sU', 'MyTransform', 'aw')


call InsertExampleMultilineText('multiple text object')
normal 2\sUU


call vimtest#SaveOut()
call vimtest#Quit()
