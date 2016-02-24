" Test text object selection mode. 

call TextTransform#MakeMappings('', '<Leader>sU', 'MyTransform', 'aw')


call InsertExampleMultilineText('single text object')
normal \sUU


call vimtest#SaveOut()
call vimtest#Quit()
