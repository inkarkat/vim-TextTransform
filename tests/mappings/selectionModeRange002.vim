" Test range selection mode with offsets.

edit ../ranges.txt
call TextTransform#MakeMappings('', '<Leader>sU', 'MyTransform', [[['^BEGIN$', '+1'], ['^END$', '-1']]])

25normal \sUU
14normal \sUU
6normal \sUU

call vimtest#SaveOut()
call vimtest#Quit()
