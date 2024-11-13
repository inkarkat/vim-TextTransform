" Test range selection mode.

edit ../ranges.txt
call TextTransform#MakeMappings('', '<Leader>sU', 'MyTransform', [['^BEGIN$', '^END$']])

25normal \sUU
14normal \sUU
6normal \sUU

call vimtest#SaveOut()
call vimtest#Quit()
