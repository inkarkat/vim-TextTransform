" Test text object selection mode at the end of the line.
" Tests that the replacement is done at the right position, not one to the left.

call TextTransform#MakeMappings('', '<Leader>sU', 'MyTransform', 'aw')


call InsertExampleMultilineText('single text object')
normal! $b
normal \sUU
normal! j$h
normal \sUU
normal! j0
normal \sUU


call vimtest#SaveOut()
call vimtest#Quit()
